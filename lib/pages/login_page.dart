import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../models/staff_user.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/exora_logo.dart';
import '../widgets/success_card.dart';
import 'admin_page.dart';
import 'invigilator_page.dart';

/// Exora Staff Login Screen matching Figma specification.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _staffIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  StaffUser? _authenticatedUser;

  @override
  void dispose() {
    _staffIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    final staffId = _staffIdController.text.trim();
    final password = _passwordController.text.trim();

    final result = await AuthService().login(
      staffId: staffId,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess && result.user != null) {
      setState(() {
        _isSuccess = true;
        _authenticatedUser = result.user;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _handleContinue() {
    if (_authenticatedUser == null) return;
    if (_authenticatedUser!.role.toLowerCase() == 'admin') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AdminPage(user: _authenticatedUser!)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => InvigilatorPage(user: _authenticatedUser!),
        ),
      );
    }
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Forgot Password clicked'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
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
                                child: _isSuccess
                                    ? SuccessCard(onContinue: _handleContinue)
                                    : Form(
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

                                            // Staff ID Field
                                            CustomTextField(
                                              label: 'Staff ID',
                                              hintText: 'admin123',
                                              controller: _staffIdController,
                                              fieldKey: const Key(
                                                'staff_id_field',
                                              ),
                                              validator: (val) {
                                                if (val == null ||
                                                    val.trim().isEmpty) {
                                                  return 'Please enter your Staff ID';
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
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _rememberMe =
                                                            !_rememberMe;
                                                      });
                                                    },
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: Checkbox(
                                                            key: const Key(
                                                              'remember_me_checkbox',
                                                            ),
                                                            value: _rememberMe,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                _rememberMe =
                                                                    val ??
                                                                    false;
                                                              });
                                                            },
                                                            activeColor:
                                                                AppColors
                                                                    .primaryBlue,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                            ),
                                                            side:
                                                                const BorderSide(
                                                                  color: Color(
                                                                    0xFFD1D5DB,
                                                                  ),
                                                                  width: 1.2,
                                                                ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        const Text(
                                                          'Remember me',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: AppColors
                                                                .textMuted,
                                                          ),
                                                        ),
                                                      ],
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
