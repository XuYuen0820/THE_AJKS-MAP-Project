import 'package:flutter/foundation.dart';

import '../../../core/models/staff_user.dart';
import '../../../core/services/auth_service.dart';
import '../../profile/services/profile_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final AuthService _authService;
  final ProfileService _profileService;

  StaffUser? _user;
  String? _errorMessage;

  StaffUser get user => _user!;
  String? get errorMessage => _errorMessage;

  DashboardViewModel(this._authService, this._profileService);

  void initUser(StaffUser initialUser) {
    _user = initialUser;
  }

  void updateUser(StaffUser updated) {
    _user = updated;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    try {
      _user = await _profileService.fetchCurrentProfile();
      notifyListeners();
    } catch (_) {}
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
