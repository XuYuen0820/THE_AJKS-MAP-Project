import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/exora_logo.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final result = await AuthService().login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient: #00007A top to #D4D4FF at 3/4 height
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

          // Safe Area & Scrollable Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth < 360 ? 16.0 : 24.0,
                          vertical: 24.0,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Top Logo
                              const ExoraLogo(),
                              const SizedBox(height: 32),

                              // White Card Container
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Card Header (Center aligned)
                                            const SizedBox(
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Login',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors
                                                          .textHeadline,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                  SizedBox(height: 6),
                                                  Text(
                                                    'Welcome To Exora!',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 24),

                                            // Email Field
                                            CustomTextField(
                                              label: 'Email',
                                              hintText: 'name@example.com',
                                              controller: _emailController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              fieldKey: const Key(
                                                'email_field',
                                              ),
                                              validator: (val) {
                                                if (val == null ||
                                                    val.trim().isEmpty) {
                                                  return 'Please enter your email';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),

                                            // Password Field
                                            CustomTextField(
                                              label: 'Password',
                                              hintText: '••••••••',
                                              controller: _passwordController,
                                              obscureText: _obscurePassword,
                                              textInputAction:
                                                  TextInputAction.done,
                                              fieldKey: const Key(
                                                'password_field',
                                              ),
                                              suffixIcon: IconButton(
                                                key: const Key(
                                                  'password_toggle_button',
                                                ),
                                                icon: SvgPicture.asset(
                                                  'assets/images/eye_off.svg',
                                                  width: 18,
                                                  height: 18,
                                                  colorFilter: ColorFilter.mode(
                                                    _obscurePassword
                                                        ? AppColors.textMuted
                                                        : AppColors.primaryBlue,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscurePassword =
                                                        !_obscurePassword;
                                                  });
                                                },
                                              ),
                                              validator: (val) {
                                                if (val == null ||
                                                    val.trim().isEmpty) {
                                                  return 'Please enter your password';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),

                                            // Remember Me & Forgot Password Row
                                            SizedBox(
                                              width: double.infinity,
                                              child: Wrap(
                                                alignment:
                                                    WrapAlignment.spaceBetween,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                runSpacing: 8,
                                                children: [
                                                  const Text(
                                                    'Stay signed in until you log out',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors.textMuted,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    key: const Key(
                                                      'forgot_password_button',
                                                    ),
                                                    onTap:
                                                        _handleForgotPassword,
                                                    child: const Text(
                                                      'Forgot Password ?',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors.linkBlue,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 24),

                                            // Log In Action Button
                                            CustomButton(
                                              text: 'Log In',
                                              isLoading: _isLoading,
                                              onPressed: _handleLogin,
                                              buttonKey: const Key(
                                                'login_button',
                                              ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
