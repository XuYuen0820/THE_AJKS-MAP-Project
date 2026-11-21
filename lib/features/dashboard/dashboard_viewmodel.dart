import 'package:flutter/foundation.dart';

import '../../models/staff_user.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final AuthService _authService;
  final ProfileService _profileService;

  StaffUser _user;
  StaffUser get user => _user;

  DashboardViewModel({
    required StaffUser initialUser,
    AuthService? authService,
    ProfileService? profileService,
  }) : _user = initialUser,
       _authService = authService ?? AuthService(),
       _profileService = profileService ?? ProfileService();

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

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
