import 'dart:convert';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/staff_user.dart';
import '../../widgets/dashboard_action_item.dart';
import '../../widgets/exam_card.dart';
import '../../widgets/exora_logo.dart';
import '../profile/profile_view.dart';
import 'dashboard_viewmodel.dart';

class InvigilatorDashboardView extends StatefulWidget {
  final StaffUser user;
  const InvigilatorDashboardView({super.key, required this.user});

  @override
  State<InvigilatorDashboardView> createState() =>
      _InvigilatorDashboardViewState();
}

class _InvigilatorDashboardViewState extends State<InvigilatorDashboardView> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel(initialUser: widget.user);
    _viewModel.refreshProfile();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _handleAction(String actionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$actionName selected'),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _viewModel.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to log out: $e')));
    }
  }

  Future<void> _openProfile() async {
    final updatedUser = await Navigator.push<StaffUser>(
      context,
      MaterialPageRoute(builder: (_) => ProfileView(user: _viewModel.user)),
    );

    if (updatedUser != null && mounted) {
      _viewModel.updateUser(updatedUser);
    } else {
      _viewModel.refreshProfile();
    }
  }

  Widget _buildDashboardAvatar(StaffUser user) {
    final avatarData = user.avatarPath;
    Widget child = const Icon(
      Icons.person_rounded,
      size: 36,
      color: AppColors.primaryBlue,
    );

    if (avatarData != null && avatarData.isNotEmpty) {
      try {
        child = Image.memory(
          base64Decode(avatarData),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        );
      } catch (_) {}
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEFF4FF),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: ClipOval(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final user = _viewModel.user;
        final greetingSuffix = user.staffId == 'staff123'
            ? 'DR TAN.'
            : '${user.name.split(' ').first}.';

        return Scaffold(
          key: const Key('invigilator_page'),
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
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ExoraLogo(
                            mainAxisAlignment: MainAxisAlignment.start,
                            iconSize: 24,
                            textHeight: 16,
                          ),
                          const SizedBox(height: 28),
                          Text.rich(
                            TextSpan(
                              text: 'WELCOME, ',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              children: [
                                TextSpan(
                                  text: greetingSuffix,
                                  style: const TextStyle(
                                    color: Color(0xFFD0BCFF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _openProfile,
                            child: Container(
                              key: const Key('invigilator_profile_card'),
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _buildDashboardAvatar(user),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.role.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00007A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.more_vert,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DashboardActionItem(
                                  itemKey: const Key(
                                    'invigilator_action_qr_scanner',
                                  ),
                                  icon: const Icon(
                                    Icons.qr_code_scanner_rounded,
                                    color: AppColors.primaryBlue,
                                    size: 28,
                                  ),
                                  label: 'QR\nScanner',
                                  onTap: () => _handleAction('QR Scanner'),
                                ),
                              ),
                              Expanded(
                                child: DashboardActionItem(
                                  itemKey: const Key(
                                    'invigilator_action_attendance_analysis',
                                  ),
                                  icon: const Icon(
                                    Icons.bar_chart_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 28,
                                  ),
                                  label: 'Attendance\nAnalysis',
                                  onTap: () =>
                                      _handleAction('Attendance Analysis'),
                                ),
                              ),
                              Expanded(
                                child: DashboardActionItem(
                                  itemKey: const Key(
                                    'invigilator_action_attendance_report',
                                  ),
                                  icon: const Icon(
                                    Icons.insert_drive_file_outlined,
                                    color: Color(0xFF3B82F6),
                                    size: 28,
                                  ),
                                  label: 'Attendance\nReport',
                                  onTap: () =>
                                      _handleAction('Attendance Report'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Upcoming Exam',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ExamCard(
                            courseCode: 'SECJ3553',
                            courseTitle: 'ARTIFICIAL INTELLIGENCE',
                            onTap: () => _handleAction('SECJ3553'),
                          ),
                          ExamCard(
                            courseCode: 'SECJ3623',
                            courseTitle: 'MOBILE APPLICATION DEVELOPMENT',
                            onTap: () => _handleAction('SECJ3623'),
                          ),
                          ExamCard(
                            courseCode: 'SECV3104',
                            courseTitle: 'APPLICATION DEVELOPMENT',
                            onTap: () => _handleAction('SECV3104'),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              key: const Key('logout_button'),
                              onPressed: _handleLogout,
                              child: const Text(
                                'Log out',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A4459),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
