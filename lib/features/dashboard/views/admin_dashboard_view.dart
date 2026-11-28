import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/models/staff_user.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/dashboard_action_item.dart';
import '../../../core/widgets/exam_card.dart';
import '../../../core/widgets/exora_logo.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'dashboard_profile_card.dart';

class AdminDashboardView extends StatefulWidget {
  final StaffUser user;
  final DashboardViewModel viewModel;

  const AdminDashboardView({
    super.key,
    required this.user,
    required this.viewModel,
  });

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
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

  void _openCollectionOverview({String examId = 'exam001'}) {
    Navigator.pushNamed(
      context,
      AppRouter.collectionAssignment,
      arguments: {'user': widget.viewModel.user, 'examId': examId},
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
        final greetingSuffix = user.staffId == 'admin123'
            ? 'MR ALI.'
            : '${user.name.split(' ').first.toUpperCase()}.';

        return Scaffold(
          key: const Key('admin_page'),
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
                            cardKey: const Key('admin_profile_card'),
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
                                    'admin_action_attendance_record',
                                  ),
                                  icon: const Icon(
                                    Icons.account_box_rounded,
                                    color: AppColors.primaryBlue,
                                    size: 28,
                                  ),
                                  label: 'Attendance\nRecord',
                                  onTap: () =>
                                      _handleAction('Attendance Record'),
                                ),
                              ),
                              Expanded(
                                child: DashboardActionItem(
                                  itemKey: const Key(
                                    'admin_action_script_tracking',
                                  ),
                                  icon: const Icon(
                                    Icons.list_alt_rounded,
                                    color: Color(0xFF1D4ED8),
                                    size: 28,
                                  ),
                                  label: 'Answer Script\nTracking',
                                  onTap: () => _openCollectionOverview(
                                    examId: 'exam001',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Exam Hall Overview',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ExamCard(
                            courseCode: 'SECJ 3553',
                            courseTitle: 'ARTIFICIAL INTELLIGENCE',
                            date: '25 November 2026',
                            venue: 'Dewan Sultan Iskandar',
                            onTap: () =>
                                _openCollectionOverview(examId: 'exam001'),
                          ),
                          ExamCard(
                            courseCode: 'SECJ 3623',
                            courseTitle: 'MOBILE APPLICATION DEVELOPMENT',
                            date: '28 November 2026',
                            venue: 'Dewan Sultan Iskandar',
                            onTap: () =>
                                _openCollectionOverview(examId: 'exam001'),
                          ),
                          ExamCard(
                            courseCode: 'SECV 3104',
                            courseTitle: 'APPLICATION DEVELOPMENT',
                            date: '5 October 2026',
                            venue: 'MPK 1, N28A',
                            onTap: () =>
                                _openCollectionOverview(examId: 'exam001'),
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
