import 'package:flutter/foundation.dart';

import '../../../core/services/auth_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthService _authService;

  ForgotPasswordViewModel(this._authService);

  bool _isLoading = false;
  String? _statusMessage;
  bool _isError = false;

  bool get isLoading => _isLoading;
  String? get statusMessage => _statusMessage;
  bool get isError => _isError;

  Future<void> sendResetEmail(String email) async {
    _isLoading = true;
    _statusMessage = null;
    _isError = false;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _statusMessage =
          'If this email has an account, Firebase sent a password reset link.';
      _isError = false;
    } catch (e) {
      _statusMessage = e.toString().replaceFirst('Exception: ', '');
      _isError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
