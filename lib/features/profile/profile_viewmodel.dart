import 'package:flutter/foundation.dart';

import '../../models/staff_user.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService;
  final AuthService _authService;

  StaffUser _user;
  bool _isLoading = false;
  bool _showPasswordHint = false;

  StaffUser get user => _user;
  bool get isLoading => _isLoading;
  bool get showPasswordHint => _showPasswordHint;

  ProfileViewModel({
    required StaffUser initialUser,
    ProfileService? profileService,
    AuthService? authService,
  }) : _user = initialUser,
       _profileService = profileService ?? ProfileService(),
       _authService = authService ?? AuthService();

  void togglePasswordHint() {
    _showPasswordHint = !_showPasswordHint;
    notifyListeners();
  }

  void setUser(StaffUser updated) {
    _user = updated;
    notifyListeners();
  }

  Future<void> loadLatestProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _profileService.fetchCurrentProfile();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<StaffUser?> saveProfileChanges({
    required String newPassword,
    Uint8List? avatarBytes,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _profileService.updateProfile(
        currentUser: _user,
        newPassword: newPassword,
        avatarBytes: avatarBytes,
      );
      return _user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
