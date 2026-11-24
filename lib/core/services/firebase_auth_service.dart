import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/staff_user.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<void> configureWebPersistence() async {
    if (kIsWeb) {
      await _auth.setPersistence(Persistence.LOCAL);
    }
  }

  bool get _isFirebaseConfigured {
    if (Firebase.apps.isEmpty) return false;
    try {
      final projectId = Firebase.app().options.projectId;
      return projectId.isNotEmpty &&
          !projectId.contains('placeholder') &&
          !projectId.contains('demo');
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> login({required String email, required String password}) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      throw Exception('Email and Password cannot be empty.');
    }
    if (!_isFirebaseConfigured) {
      throw Exception(
        'Firebase is not configured. Please check your connection.',
      );
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        throw Exception('Invalid email or password.');
      }
      if (e.code == 'user-disabled') {
        throw Exception('This Firebase account has been disabled.');
      }
      if (e.code == 'too-many-requests') {
        throw Exception('Too many attempts. Please try again later.');
      }
      if (e.code == 'network-request-failed') {
        throw Exception('Check your internet connection and retry.');
      }
      throw Exception(e.message ?? 'Firebase sign-in failed (${e.code}).');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw Exception('Please enter a valid email address.');
      }
      if (e.code == 'network-request-failed') {
        throw Exception('Check your internet connection and try again.');
      }
      throw Exception('Could not send the reset email. Please try again.');
    }
  }

  @override
  Future<StaffUser> fetchStaffProfile(String email) async {
    final querySnap = await _firestore
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

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
