import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/exora_logo.dart';
import 'forgot_password_view.dart';
import 'login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _viewModel = LoginViewModel();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await _viewModel.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted || success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewModel.errorMessage ?? 'Login failed'),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.75, 1.0],
                    colors: [
                      AppColors.backgroundTop,
                      AppColors.backgroundBottom,
                      AppColors.backgroundBottom,
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ExoraLogo(),
                          const SizedBox(height: 32),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        Text(
                                          'Login',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textHeadline,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Welcome To Exora!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  CustomTextField(
                                    label: 'Email',
                                    hintText: 'name@example.com',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    fieldKey: const Key('email_field'),
                                    validator: (val) =>
                                        (val == null || val.trim().isEmpty)
                                        ? 'Please enter your email'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    label: 'Password',
                                    hintText: '••••••••',
                                    controller: _passwordController,
                                    obscureText: _viewModel.obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    fieldKey: const Key('password_field'),
                                    suffixIcon: IconButton(
                                      key: const Key('password_toggle_button'),
                                      icon: SvgPicture.asset(
                                        'assets/images/eye_off.svg',
                                        width: 18,
                                        height: 18,
                                        colorFilter: ColorFilter.mode(
                                          _viewModel.obscurePassword
                                              ? AppColors.textMuted
                                              : AppColors.primaryBlue,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      onPressed:
                                          _viewModel.togglePasswordVisibility,
                                    ),
                                    validator: (val) =>
                                        (val == null || val.trim().isEmpty)
                                        ? 'Please enter your password'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Stay signed in until you log out',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        key: const Key(
                                          'forgot_password_button',
                                        ),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ForgotPasswordView(),
                                          ),
                                        ),
                                        child: const Text(
                                          'Forgot Password ?',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.linkBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  CustomButton(
                                    text: 'Log In',
                                    isLoading: _viewModel.isLoading,
                                    onPressed: _onLoginPressed,
                                    buttonKey: const Key('login_button'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
