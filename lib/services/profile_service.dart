import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/staff_user.dart';
import 'auth_service.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches real-time staff profile information from Firestore 'account' collection.
  Future<StaffUser> fetchProfile(String staffId) async {
    final query = await _firestore
        .collection('account')
        .where('staffId', isEqualTo: staffId.trim().toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Staff account not found in Firebase.');
    }

    final doc = query.docs.first;
    return StaffUser.fromMap(doc.data(), doc.id);
  }

  /// Updates ONLY passwordHash and/or avatarBase64 in Firestore.
  Future<StaffUser> updateProfile({
    required StaffUser currentUser,
    required String newPassword,
    Uint8List? avatarBytes,
  }) async {
    final query = await _firestore
        .collection('account')
        .where('staffId', isEqualTo: currentUser.staffId.trim().toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Staff account not found in Firebase.');
    }

    final docRef = query.docs.first.reference;
    final Map<String, dynamic> updates = {};

    // 1. Update password in Firebase if a new password was provided
    final cleanPassword = newPassword.trim();
    if (cleanPassword.isNotEmpty) {
      updates['passwordHash'] = AuthService.hashPassword(cleanPassword);
    }

    // 2. Encode picked image bytes to Base64 and save to Firestore
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
