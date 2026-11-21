import 'package:flutter/foundation.dart';

import '../../services/auth_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthService _authService;

  ForgotPasswordViewModel({AuthService? authService})
    : _authService = authService ?? AuthService();

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

    final result = await _authService.sendPasswordResetEmail(email);

    _isLoading = false;
    _statusMessage = result.message;
    _isError = !result.isSuccess;
    notifyListeners();
  }
}
