import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/staff_user.dart';

/// Result wrapper for authentication attempts.
class AuthResult {
  final bool isSuccess;
  final String message;
  final StaffUser? user;

  AuthResult({required this.isSuccess, required this.message, this.user});

  factory AuthResult.success(
    StaffUser user, {
    String message = 'Login successful',
  }) {
    return AuthResult(isSuccess: true, message: message, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult(isSuccess: false, message: message);
  }
}

/// Service handling staff authentication with Cloud Firestore.
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  FirebaseFirestore? _firestore;

  FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  /// Hashes a password using SHA-256.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password.trim());
    return sha256.convert(bytes).toString();
  }

  /// Checks whether Firebase is configured.
  bool get isFirebaseConfigured {
    if (Firebase.apps.isEmpty) return false;

    try {
      final projectId = Firebase.app().options.projectId;

      return projectId.isNotEmpty &&
          projectId != 'demo-exora-map' &&
          !projectId.contains('placeholder') &&
          !projectId.contains('demo');
    } catch (_) {
      return false;
    }
  }

  /// Authenticates staff using their Firestore account in the 'account' collection.
  Future<AuthResult> login({
    required String staffId,
    required String password,
  }) async {
    final cleanStaffId = staffId.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanStaffId.isEmpty || cleanPassword.isEmpty) {
      return AuthResult.failure('Staff ID and Password cannot be empty.');
    }

    if (!isFirebaseConfigured) {
      return AuthResult.failure(
        'Firebase is not configured. Please check your connection.',
      );
    }

    try {
      final querySnap = await firestore
          .collection('account')
          .where('staffId', isEqualTo: cleanStaffId)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      if (querySnap.docs.isEmpty) {
        return AuthResult.failure(
          'Staff account "$cleanStaffId" does not exist.',
        );
      }

      final docSnap = querySnap.docs.first;
      final docRef = docSnap.reference;
      final data = docSnap.data();
      final user = StaffUser.fromMap(data, docSnap.id);

      if (!user.isActive) {
        return AuthResult.failure('This staff account has been deactivated.');
      }

      final inputHash = hashPassword(cleanPassword);

      // Supports existing plaintext passwords (e.g., "staff123") and SHA-256 hashes.
      final passwordMatches =
          user.passwordHash == inputHash || user.passwordHash == cleanPassword;

      if (!passwordMatches) {
        return AuthResult.failure('Incorrect password. Please try again.');
      }

      // Update the last login time in Firestore.
      await docRef.update({'lastLoginAt': DateTime.now().toIso8601String()});

      return AuthResult.success(user, message: 'Welcome back, ${user.name}!');
    } on TimeoutException {
      return AuthResult.failure(
        'Network timeout: Could not reach Firebase server.',
      );
    } on FirebaseException catch (e) {
      return AuthResult.failure('Firebase error: ${e.message ?? e.code}');
    } catch (e) {
      return AuthResult.failure('Login error: $e');
    }
  }
}
