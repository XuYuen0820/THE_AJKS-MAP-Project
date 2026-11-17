import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/staff_user.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the signed-in user's profile from Firestore.
  Future<StaffUser> fetchCurrentProfile() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final email = firebaseUser?.email;

    if (email == null || email.isEmpty) {
      throw Exception('You must be signed in to load your profile.');
    }

    final query = await _firestore
        .collection('account')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Your staff profile was not found in Firebase.');
    }

    final doc = query.docs.first;
    return StaffUser.fromMap(doc.data(), doc.id);
  }

  /// Updates the Firebase password and/or the avatar stored in Firestore.
  Future<StaffUser> updateProfile({
    required StaffUser currentUser,
    required String newPassword,
    Uint8List? avatarBytes,
  }) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final email = firebaseUser?.email;

    if (email == null || email.isEmpty) {
      throw Exception('You must be signed in to update your profile.');
    }
    if (email.trim().toLowerCase() != currentUser.email.trim().toLowerCase()) {
      throw Exception('The signed-in account does not match this profile.');
    }

    final query = await _firestore
        .collection('account')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Your staff profile was not found in Firebase.');
    }

    final docRef = query.docs.first.reference;
    final Map<String, dynamic> updates = {};

    final cleanPassword = newPassword.trim();
    if (cleanPassword.isNotEmpty) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('You must be signed in to change your password.');
      }

      await firebaseUser.updatePassword(cleanPassword);
    }

    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      updates['avatarBase64'] = base64Encode(avatarBytes);
    }

    if (updates.isNotEmpty) {
      await docRef.update(updates);
    }

    final refreshedSnap = await docRef.get();
    return StaffUser.fromMap(refreshedSnap.data()!, refreshedSnap.id);
  }
}
