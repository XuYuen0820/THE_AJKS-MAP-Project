import 'package:flutter/material.dart';

import '../../../app/dependencies.dart';
import '../../../app/router.dart';
import '../../../core/models/staff_user.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/dashboard_action_item.dart';
import '../../../core/widgets/exora_logo.dart';
import '../../collection_assignment/models/collection_area_assignment.dart';
import '../../collection_assignment/services/collection_assignment_service.dart';
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
  List<CollectionAreaAssignment> _myAssignments = [];
  bool _loadingAssignments = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initUser(widget.user);
    widget.viewModel.refreshProfile();
    _loadMyAssignedZones();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  /// Fetches ONLY collection_assignments where collectorStaffID == currentUser.staffId
  Future<void> _loadMyAssignedZones() async {
    setState(() => _loadingAssignments = true);
    try {
      final service = dependency<CollectionAssignmentService>();
      final zones = await service.fetchAssignments(
        examId: 'exam001',
        currentUser: widget.viewModel.user,
      );
      if (mounted) {
        setState(() => _myAssignments = zones);
      }
    } catch (_) {
      // Handle offline state gracefully
    } finally {
      if (mounted) setState(() => _loadingAssignments = false);
    }
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

  Future<void> _openMyCollectionArea({String examId = 'exam001'}) async {
    await Navigator.pushNamed(
      context,
      AppRouter.collectionAssignment,
      arguments: {'user': widget.viewModel.user, 'examId': examId},
    );
    _loadMyAssignedZones();
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
        final firstName = user.name.trim().split(' ').first.toUpperCase();

        return Scaffold(
          key: const Key('invigilator_page'),
          body: Container(
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
            child: SafeArea(
              child: SingleChildScrollView(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 36),
                            const ExoraLogo(
                              mainAxisAlignment: MainAxisAlignment.center,
                              iconSize: 24,
                              textHeight: 16,
                            ),
                            InkWell(
                              onTap: _openProfile,
                              borderRadius: BorderRadius.circular(20),
                              child: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 20,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'WELCOME BACK, ',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(
                                  text: '$firstName.',
                                  style: const TextStyle(
                                    color: Color(0xFFD0BCFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        DashboardProfileCard(
                          user: user,
                          cardKey: const Key('invigilator_profile_card'),
                          onTap: _openProfile,
                        ),
                        const SizedBox(height: 24),

                        // 3 Main Function Action Items
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DashboardActionItem(
                                icon: const Icon(
                                  Icons.qr_code_scanner_rounded,
                                  color: AppColors.primaryBlue,
                                  size: 28,
                                ),
                                label: 'QR Scan\nAttendance',
                                onTap: () =>
                                    _handleAction('QR Scan Attendance'),
                              ),
                            ),
                            Expanded(
                              child: DashboardActionItem(
                                icon: const Icon(
                                  Icons.account_box_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 28,
                                ),
                                label: 'Attendance\nRecord',
                                onTap: () => _handleAction('Attendance Record'),
                              ),
                            ),
                            Expanded(
                              child: DashboardActionItem(
                                icon: const Icon(
                                  Icons.list_alt_rounded,
                                  color: Color(0xFF1D4ED8),
                                  size: 28,
                                ),
                                label: 'Answer Script\nTracking',
                                onTap: () =>
                                    _openMyCollectionArea(examId: 'exam001'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // MY ASSIGNED COLLECTION AREA CARD (Placed under the functions)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D6FE),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'MY ASSIGNED COLLECTION AREA',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E1B4B),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _loadMyAssignedZones,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.refresh_rounded,
                                          size: 16,
                                          color: _loadingAssignments
                                              ? Colors.grey
                                              : const Color(0xFF1E1B4B),
                                        ),
                                        const SizedBox(width: 3),
                                        const Text(
                                          'Refresh',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E1B4B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_loadingAssignments)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: LinearProgressIndicator(),
                                )
                              else if (_myAssignments.isEmpty)
                                const Text(
                                  'No collection zone assigned to you yet. Tap Refresh after Lead Invigilator assigns your seats.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF374151),
                                  ),
                                )
                              else
                                ..._myAssignments.map(
                                  (zone) => InkWell(
                                    onTap: () => _openMyCollectionArea(
                                      examId: zone.examId,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${zone.courseCode} • Seats ${zone.formattedRange}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                              Text(
                                                'View my assigned seats (${(zone.seatEnd - zone.seatStart) + 1} seats)',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF374151),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 15,
                                            color: Color(0xFF1E1B4B),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Exam Hall',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user.role.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1B4B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _InvigilatorExamCard(
                          status: 'Ongoing',
                          courseCode: 'SECJ3553',
                          courseTitle: 'ARTIFICIAL INTELLIGENCE - 5, 6',
                          dateTime: '25 November 2026 | 9:00 AM - 12:00 PM',
                          venue: 'Dewan Sultan Iskandar (DSI)',
                          assignedRangeText: _myAssignments.isNotEmpty
                              ? 'My Zone: ${_myAssignments.map((z) => z.formattedRange).join(', ')}'
                              : 'Not assigned yet',
                          onTap: () => _openMyCollectionArea(examId: 'exam001'),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InvigilatorExamCard extends StatelessWidget {
  final String status;
  final String courseCode;
  final String courseTitle;
  final String dateTime;
  final String venue;
  final String assignedRangeText;
  final VoidCallback onTap;

  const _InvigilatorExamCard({
    required this.status,
    required this.courseCode,
    required this.courseTitle,
    required this.dateTime,
    required this.venue,
    required this.assignedRangeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    assignedRangeText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                courseCode,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeadline,
                ),
              ),
              Text(
                courseTitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeadline,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dateTime,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                venue,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
