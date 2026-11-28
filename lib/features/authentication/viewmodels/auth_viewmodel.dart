import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/models/staff_user.dart';
import '../../../../core/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _authSub;

  StaffUser? currentUser;
  bool isLoading = true;
  String? errorMessage;

  AuthViewModel(this._authService) {
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authSub = _authService.authStateChanges.listen((firebaseUser) async {
      final email = firebaseUser?.email;
      if (firebaseUser == null || email == null || email.isEmpty) {
        currentUser = null;
        errorMessage = null;
        isLoading = false;
        notifyListeners();
        return;
      }

      isLoading = true;
      errorMessage = null;
      notifyListeners();

      try {
        final staff = await _authService.fetchStaffProfile(email);
        if (!staff.isActive) {
          errorMessage = 'This staff account has been deactivated.';
          currentUser = null;
        } else {
          currentUser = staff;
        }
      } catch (e) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        currentUser = null;
      } finally {
        isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
