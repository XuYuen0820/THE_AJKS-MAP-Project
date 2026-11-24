import 'dart:typed_data';

import '../../../core/models/staff_user.dart';

abstract class ProfileService {
  Future<StaffUser> fetchCurrentProfile();
  Future<StaffUser> updateProfile({
    required StaffUser currentUser,
    required String newPassword,
    Uint8List? avatarBytes,
  });
}
