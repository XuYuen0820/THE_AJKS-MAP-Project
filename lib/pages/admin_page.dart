import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/staff_user.dart';
import '../widgets/dashboard_action_item.dart';
import '../widgets/exam_card.dart';
import '../widgets/exora_logo.dart';
import 'login_page.dart';

/// Admin Dashboard Screen matching Figma node 1:1156.
class AdminPage extends StatelessWidget {
  final StaffUser user;

  const AdminPage({super.key, required this.user});

  void _handleAction(BuildContext context, String actionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$actionName selected'),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final greetingSuffix = user.staffId == 'admin123'
        ? 'MR ALI.'
        : '${user.name.split(' ').first}.';

    return Scaffold(
      key: const Key('admin_page'),
      body: Stack(
        children: [
          // Background Gradient matching Figma specs
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Brand Header
                      const ExoraLogo(
                        mainAxisAlignment: MainAxisAlignment.start,
                        iconSize: 24,
                        textHeight: 16,
                      ),
                      const SizedBox(height: 28),

                      // Welcome Title
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

                      // Profile Card Container
                      Container(
                        key: const Key('admin_profile_card'),
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
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFEFF4FF),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 36,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 28),

                      // Dashboard Header
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dashboard 4-Action Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DashboardActionItem(
                              itemKey: const Key('admin_action_qr_scanner'),
                              icon: const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: AppColors.primaryBlue,
                                size: 28,
                              ),
                              label: 'QR\nScanner',
                              onTap: () => _handleAction(context, 'QR Scanner'),
                            ),
                          ),
                          Expanded(
                            child: DashboardActionItem(
                              itemKey: const Key(
                                'admin_action_attendance_analysis',
                              ),
                              icon: const Icon(
                                Icons.bar_chart_rounded,
                                color: Color(0xFF2563EB),
                                size: 28,
                              ),
                              label: 'Attendance\nAnalysis',
                              onTap: () =>
                                  _handleAction(context, 'Attendance Analysis'),
                            ),
                          ),
                          Expanded(
                            child: DashboardActionItem(
                              itemKey: const Key(
                                'admin_action_attendance_report',
                              ),
                              icon: const Icon(
                                Icons.insert_drive_file_outlined,
                                color: Color(0xFF3B82F6),
                                size: 28,
                              ),
                              label: 'Attendance\nReport',
                              onTap: () =>
                                  _handleAction(context, 'Attendance Report'),
                            ),
                          ),
                          Expanded(
                            child: DashboardActionItem(
                              itemKey: const Key(
                                'admin_action_invigilator_management',
                              ),
                              icon: const Icon(
                                Icons.manage_accounts_outlined,
                                color: Color(0xFF1D4ED8),
                                size: 28,
                              ),
                              label: 'Invigilator\nManagement',
                              onTap: () => _handleAction(
                                context,
                                'Invigilator Management',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Upcoming Exam Header
                      const Text(
                        'Upcoming Exam',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Examination Course Cards
                      ExamCard(
                        courseCode: 'SECJ3553',
                        courseTitle: 'ARTIFICIAL INTELLIGENCE',
                        onTap: () => _handleAction(context, 'SECJ3553'),
                      ),
                      ExamCard(
                        courseCode: 'SECJ3623',
                        courseTitle: 'MOBILE APPLICATION DEVELOPMENT',
                        onTap: () => _handleAction(context, 'SECJ3623'),
                      ),
                      ExamCard(
                        courseCode: 'SECV3104',
                        courseTitle: 'APPLICATION DEVELOPMENT',
                        onTap: () => _handleAction(context, 'SECV3104'),
                      ),
                      const SizedBox(height: 24),

                      // Logout Link
                      Center(
                        child: TextButton(
                          key: const Key('logout_button'),
                          onPressed: () => _handleLogout(context),
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
  }
}
