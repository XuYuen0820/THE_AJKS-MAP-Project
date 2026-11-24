import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/models/staff_user.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/dashboard_action_item.dart';
import '../../../core/widgets/exam_card.dart';
import '../../../core/widgets/exora_logo.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'dashboard_profile_card.dart';

class InvigilatorDashboardView extends StatefulWidget {
  final StaffUser user;
  final DashboardViewModel viewModel;

  const InvigilatorDashboardView({
    super.key,
    required this.user,
    required this.viewModel,
  });

  @override
  State<InvigilatorDashboardView> createState() =>
      _InvigilatorDashboardViewState();
}

class _InvigilatorDashboardViewState extends State<InvigilatorDashboardView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initUser(widget.user);
    widget.viewModel.refreshProfile();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
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
    final success = await widget.viewModel.signOut();
    if (!mounted) return;
    if (!success && widget.viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to log out: ${widget.viewModel.errorMessage}'),
        ),
      );
    }
  }

  Future<void> _openProfile() async {
    final updatedUser = await Navigator.pushNamed(
      context,
      AppRouter.profile,
      arguments: widget.viewModel.user,
    ) as StaffUser?;

    if (!mounted) return;
    if (updatedUser != null) {
      widget.viewModel.updateUser(updatedUser);
    } else {
      widget.viewModel.refreshProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final user = widget.viewModel.user;
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
                          DashboardProfileCard(
                            user: user,
                            cardKey: const Key('invigilator_profile_card'),
                            onTap: _openProfile,
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
