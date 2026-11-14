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

  AuthResult({
    required this.isSuccess,
    required this.message,
    this.user,
  });

  factory AuthResult.success(StaffUser user, {String message = 'Login successful'}) {
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

  /// Hashes password with SHA-256 for secure comparison.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password.trim());
    return sha256.convert(bytes).toString();
  }

  /// Checks if a valid, production Firebase project has been configured.
  bool get isFirebaseConfigured {
    if (Firebase.apps.isEmpty) return false;
    try {
      final projectId = Firebase.app().options.projectId;
      if (projectId.isEmpty ||
          projectId == 'demo-exora-map' ||
          projectId.contains('placeholder') ||
          projectId.contains('demo')) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Authenticates staff credentials.
  Future<AuthResult> login({
    required String staffId,
    required String password,
  }) async {
    final cleanStaffId = staffId.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanStaffId.isEmpty || cleanPassword.isEmpty) {
      return AuthResult.failure('Staff ID and Password cannot be empty.');
    }

    // 1. Hardcoded evaluation accounts for testing
    if (cleanStaffId == 'admin123' && cleanPassword == 'admin123') {
      await Future.delayed(const Duration(milliseconds: 500));
      return AuthResult.success(
        StaffUser(
          staffId: 'admin123',
          name: 'MR ALI BIN BAKAR',
          role: 'Admin',
          passwordHash: hashPassword('admin123'),
        ),
        message: 'Login successful! Welcome back, Admin.',
      );
    }

    if (cleanStaffId == 'staff123' && cleanPassword == 'staff123') {
      await Future.delayed(const Duration(milliseconds: 500));
      return AuthResult.success(
        StaffUser(
          staffId: 'staff123',
          name: 'DR TAN BEE LAN',
          role: 'Invigilator',
          passwordHash: hashPassword('staff123'),
        ),
        message: 'Login successful! Welcome back, Invigilator.',
      );
    }

    // 2. Offline / Demo mode fallback when Firebase project credentials are pending
    if (!isFirebaseConfigured) {
      await Future.delayed(const Duration(milliseconds: 500));
      return AuthResult.failure(
        'Invalid credentials. (Test accounts: admin123/admin123 or staff123/staff123)',
      );
    }

    // 3. Cloud Firestore real-time authentication
    try {
      final docRef = firestore.collection('staff').doc(cleanStaffId);
      final docSnap = await docRef
          .get()
          .timeout(const Duration(seconds: 4));

      if (!docSnap.exists || docSnap.data() == null) {
        // Auto-seed default accounts if collection is freshly initialized
        if (cleanStaffId == 'admin123' || cleanStaffId == 'staff123') {
          await seedDefaultAdminAccount();
          final seededSnap = await docRef
              .get()
              .timeout(const Duration(seconds: 4));
          if (seededSnap.exists && seededSnap.data() != null) {
            return _verifyPasswordAndReturn(seededSnap, cleanPassword);
          }
        }
        return AuthResult.failure('Staff account "$cleanStaffId" does not exist.');
      }

      return _verifyPasswordAndReturn(docSnap, cleanPassword);
    } on TimeoutException {
      return AuthResult.failure('Network timeout: Could not reach Firebase server.');
    } catch (e) {
      return AuthResult.failure('Database error: ${e.toString()}');
    }
  }

  AuthResult _verifyPasswordAndReturn(
    DocumentSnapshot<Map<String, dynamic>> docSnap,
    String plainPassword,
  ) {
    final data = docSnap.data()!;
    final user = StaffUser.fromMap(data, docSnap.id);

    if (!user.isActive) {
      return AuthResult.failure('This staff account has been deactivated.');
    }

    final inputHash = hashPassword(plainPassword);
    final passwordMatches =
        user.passwordHash == inputHash || user.passwordHash == plainPassword;

    if (!passwordMatches) {
      return AuthResult.failure('Incorrect password. Please try again.');
    }

    // Update lastLoginAt timestamp asynchronously
    docSnap.reference.update({
      'lastLoginAt': DateTime.now().toIso8601String(),
    }).catchError((_) {});

    return AuthResult.success(user, message: 'Welcome back, ${user.name}!');
  }

  /// Auto-seeds test accounts into Firestore.
  Future<void> seedDefaultAdminAccount() async {
    if (!isFirebaseConfigured) return;
    try {
      final adminRef = firestore.collection('staff').doc('admin123');
      final adminExists = (await adminRef
              .get()
              .timeout(const Duration(seconds: 4)))
          .exists;
      if (!adminExists) {
        final defaultAdmin = StaffUser(
          staffId: 'admin123',
          name: 'MR ALI BIN BAKAR',
          role: 'Admin',
          passwordHash: hashPassword('admin123'),
          createdAt: DateTime.now(),
        );
        await adminRef.set(defaultAdmin.toMap());
      }

      final staffRef = firestore.collection('staff').doc('staff123');
      final staffExists = (await staffRef
              .get()
              .timeout(const Duration(seconds: 4)))
          .exists;
      if (!staffExists) {
        final defaultStaff = StaffUser(
          staffId: 'staff123',
          name: 'DR TAN BEE LAN',
          role: 'Invigilator',
          passwordHash: hashPassword('staff123'),
          createdAt: DateTime.now(),
        );
        await staffRef.set(defaultStaff.toMap());
      }
    } catch (_) {}
  }
}
