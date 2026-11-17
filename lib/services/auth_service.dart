import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/staff_user.dart';

/// Result wrapper for authentication attempts.
class AuthResult {
  final bool isSuccess;
  final String message;

  AuthResult({required this.isSuccess, required this.message});

  factory AuthResult.success({String message = 'Login successful'}) {
    return AuthResult(isSuccess: true, message: message);
  }

  factory AuthResult.failure(String message) {
    return AuthResult(isSuccess: false, message: message);
  }
}

/// Handles Firebase Authentication sign-in and sign-out.
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  FirebaseFirestore? _firestore;

  FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
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

  /// Asks Firebase Authentication to check the email and password.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      return AuthResult.failure('Email and Password cannot be empty.');
    }

    if (!isFirebaseConfigured) {
      return AuthResult.failure(
        'Firebase is not configured. Please check your connection.',
      );
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        return AuthResult.failure('Invalid email or password.');
      }

      if (e.code == 'user-disabled') {
        return AuthResult.failure('This Firebase account has been disabled.');
      }

      if (e.code == 'too-many-requests') {
        return AuthResult.failure('Too many attempts. Please try again later.');
      }

      if (e.code == 'network-request-failed') {
        return AuthResult.failure('Check your internet connection and retry.');
      }

      return AuthResult.failure(
        e.message ?? 'Firebase sign-in failed (${e.code}).',
      );
    } catch (e) {
      return AuthResult.failure('Login error: $e');
    }
  }

  /// Loads a staff profile using the email from the signed-in Firebase account.
  Future<StaffUser> fetchStaffProfile(String email) async {
    final querySnap = await firestore
        .collection('account')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));

    if (querySnap.docs.isEmpty) {
      throw Exception('No staff profile is linked to this email address.');
    }

    final doc = querySnap.docs.first;
    await doc.reference.update({
      'lastLoginAt': DateTime.now().toIso8601String(),
    });

    return StaffUser.fromMap(doc.data(), doc.id);
  }

  /// Signs out the current Firebase Authentication user.
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
