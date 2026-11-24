
import 'package:flutter/foundation.dart';

import '../../../core/models/staff_user.dart';
import '../../../core/services/auth_service.dart';
import '../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService;
  final AuthService _authService;

  StaffUser? _user;
  bool _isLoading = false;
  bool _showPasswordHint = false;
  String? _errorMessage;

  StaffUser get user => _user!;
  bool get isLoading => _isLoading;
  bool get showPasswordHint => _showPasswordHint;
  String? get errorMessage => _errorMessage;

  ProfileViewModel(this._profileService, this._authService);

  void initUser(StaffUser initialUser) {
    _user = initialUser;
  }

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
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _profileService.fetchCurrentProfile();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _profileService.updateProfile(
        currentUser: user,
        newPassword: newPassword,
        avatarBytes: avatarBytes,
      );
      return _user;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signOut() async {
    _errorMessage = null;
    try {
      await _authService.signOut();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
