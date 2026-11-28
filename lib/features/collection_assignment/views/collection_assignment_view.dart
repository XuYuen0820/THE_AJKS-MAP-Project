import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/models/staff_user.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/exora_logo.dart';
import '../models/collection_area_assignment.dart';
import '../viewmodels/collection_assignment_viewmodel.dart';

class CollectionAssignmentView extends StatefulWidget {
  final StaffUser user;
  final CollectionAssignmentViewModel viewModel;
  final String examId;

  const CollectionAssignmentView({
    super.key,
    required this.user,
    required this.viewModel,
    this.examId = 'exam001',
  });

  @override
  State<CollectionAssignmentView> createState() =>
      _CollectionAssignmentViewState();
}

class _CollectionAssignmentViewState extends State<CollectionAssignmentView> {
  static const List<Color> _zoneCardColors = [
    Color(0xFFD9D6FE),
    Color(0xFFBAE6FD),
    Color(0xFFFEF08A),
    Color(0xFFBBF7D0),
    Color(0xFFFED7AA),
  ];

  @override
  void initState() {
    super.initState();
    widget.viewModel.init(user: widget.user, targetExamId: widget.examId);
    widget.viewModel.loadData();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _navigateToAssign() async {
    if (widget.viewModel.selectedSection == 'MY_ZONE') {
      widget.viewModel.setSectionFilter('ALL');
    }
    await Navigator.pushNamed(
      context,
      AppRouter.assignArea,
      arguments: widget.viewModel,
    );
  }

  Future<void> _navigateToEdit(CollectionAreaAssignment assignment) async {
    await Navigator.pushNamed(
      context,
      AppRouter.editAssignment,
      arguments: {'viewModel': widget.viewModel, 'assignment': assignment},
    );
  }

  Future<void> _openSwapDialog() async {
    final list = widget.viewModel.assignments;
    if (list.length < 2) {
      _showSnackBar(
        'At least 2 assigned collection areas are needed to swap.',
        isError: true,
      );
      return;
    }

    CollectionAreaAssignment first = list[0];
    CollectionAreaAssignment second = list[1];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Swap Collectors',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<CollectionAreaAssignment>(
                    initialValue: first,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'First Area',
                      border: OutlineInputBorder(),
                    ),
                    items: list
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text(
                              '${a.formattedRange} — ${a.collectorName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => first = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  const Icon(Icons.swap_vert_rounded, size: 28),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<CollectionAreaAssignment>(
                    initialValue: second,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Second Area',
                      border: OutlineInputBorder(),
                    ),
                    items: list
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text(
                              '${a.formattedRange} — ${a.collectorName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => second = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final err = await widget.viewModel.swapCollectors(
                      first: first,
                      second: second,
                    );
                    if (err != null) {
                      _showSnackBar(err, isError: true);
                    } else {
                      _showSnackBar('Collectors swapped successfully!');
                    }
                  },
                  child: const Text('Swap'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(CollectionAreaAssignment assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Assignment?'),
        content: Text(
          'Unassign ${assignment.collectorName} from ${assignment.formattedRange}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final err = await widget.viewModel.removeAssignment(assignment);
      if (err != null) {
        _showSnackBar(err, isError: true);
      } else {
        _showSnackBar('Assignment removed.');
      }
    }
  }

  void _showStudentSeatPopup(SeatStudent? student, int seatNum) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seat S${seatNum.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (student != null) ...[
              Text('Student: ${student.studentName}'),
              Text('Matric No: ${student.matricNo}'),
              Text('Section: ${student.section}'),
              Text('Attendance: ${student.attendanceStatus}'),
            ] else
              const Text('Unoccupied seat'),
          ],
        ),
      ),
    );
  }

  /// Calculates seat number following Figma layout:
  /// 5 columns, right-to-left columns, bottom-to-top rows.
  int _seatNumberAtGridPosition({
    required int rowFromTop,
    required int colFromLeft,
    required int rowsPerCol,
    required int startSeat,
  }) {
    const int numCols = 5;
    final int colFromRight = (numCols - 1) - colFromLeft;
    final int rowFromBottom = (rowsPerCol - 1) - rowFromTop;
    return startSeat + (colFromRight * rowsPerCol) + rowFromBottom;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final exam = vm.examInfo;
        final isMyZoneMode =
            !vm.isSupervisor || vm.selectedSection == 'MY_ZONE';
        final totalStart = vm.displaySeatStart;
        final totalEnd = vm.displaySeatEnd;
        final totalSeats = ((totalEnd - totalStart) + 1).clamp(1, 300);
        const int numCols = 5;
        final int rowsPerCol = (totalSeats / numCols).ceil();
        final int aisleAfterRow = (rowsPerCol * 0.625).round() - 1;

        final String sectionHeaderText;
        if (isMyZoneMode && vm.myAssignments.isNotEmpty) {
          sectionHeaderText =
              'Assigned Zone (${vm.myAssignments.map((z) => z.formattedRange).join(', ')})';
        } else if (vm.selectedSection == 'ALL') {
          sectionHeaderText = 'Section ${exam?.section ?? '5, 6'}';
        } else {
          sectionHeaderText = 'Section ${vm.selectedSection}';
        }

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
              ),
            ),
            child: SafeArea(
              child: vm.isLoading && exam == null
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: ExoraLogo(iconSize: 22, textHeight: 15),
                              ),
                              const SizedBox(height: 12),

                              // Back & Role Badge Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 32),
                                    ),
                                    child: const Text(
                                      '< Back',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
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
                                      widget.user.role.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E1B4B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Course Info Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exam?.courseCode ?? 'SECJ 3553',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                          Text(
                                            '${exam?.courseName.toUpperCase() ?? 'ARTIFICIAL INTELLIGENCE'} - ${exam?.section ?? '5, 6'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textHeadline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Text(
                                      'Seat Layout',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Section Filter Tabs + "ASSIGNED ZONE" quick tab beside SEC 06
                              if (vm.isSupervisor) ...[
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _SectionFilterPill(
                                        label: 'ALL',
                                        isSelected: vm.selectedSection == 'ALL',
                                        onTap: () => vm.setSectionFilter('ALL'),
                                      ),
                                      const SizedBox(width: 8),
                                      ...vm.availableSections.map((sec) {
                                        final padded = sec.padLeft(2, '0');
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: _SectionFilterPill(
                                            label: 'SEC $padded',
                                            isSelected:
                                                vm.selectedSection == sec,
                                            onTap: () =>
                                                vm.setSectionFilter(sec),
                                          ),
                                        );
                                      }),
                                      _SectionFilterPill(
                                        label: 'ASSIGNED ZONE',
                                        icon: Icons.person_pin_circle_rounded,
                                        isSelected:
                                            vm.selectedSection == 'MY_ZONE',
                                        onTap: () =>
                                            vm.setSectionFilter('MY_ZONE'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],

                              // Lead Invigilator Action Buttons (Assign / Edit / Swap)
                              if (vm.isLeadInvigilator)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      _ActionChipButton(
                                        label: 'Assign',
                                        icon: Icons.add,
                                        onTap: _navigateToAssign,
                                      ),
                                      const SizedBox(width: 8),
                                      _ActionChipButton(
                                        label: 'Edit',
                                        icon: Icons.edit_outlined,
                                        onTap: vm.selectedAssignment == null
                                            ? null
                                            : () => _navigateToEdit(
                                                vm.selectedAssignment!,
                                              ),
                                      ),
                                      const SizedBox(width: 8),
                                      _ActionChipButton(
                                        label: 'Swap',
                                        icon: Icons.swap_horiz_rounded,
                                        onTap: _openSwapDialog,
                                      ),
                                    ],
                                  ),
                                ),

                              // Assigned Collector Chips (Same color per collector!)
                              if (vm.assignments.isNotEmpty) ...[
                                SizedBox(
                                  height: 34,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: vm.assignments.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, idx) {
                                      final item = vm.assignments[idx];
                                      final isSelected =
                                          vm.selectedAssignment?.id == item.id;
                                      final colorIdx = vm
                                          .getAssignmentColorIndex(item);
                                      final bgColor =
                                          _zoneCardColors[colorIdx %
                                              _zoneCardColors.length];
                                      return GestureDetector(
                                        onTap: () => vm.selectAssignment(item),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF1E1B4B)
                                                  : Colors.transparent,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            '${item.formattedRange}: ${item.collectorName}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E1B4B),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],

                              // Empty state if Lead Invigilator taps ASSIGNED ZONE with no seats assigned to them yet
                              if (vm.selectedSection == 'MY_ZONE' &&
                                  vm.myAssignments.isEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    'No seats are currently assigned to your account (${widget.user.name}). Tap "+ Assign" to allocate a range to yourself.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Seat Grid Container
                              if ((vm.isSupervisor &&
                                      vm.selectedSection != 'MY_ZONE') ||
                                  vm.myAssignments.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF38BDF8),
                                      width: 1.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1A000000),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              sectionHeaderText,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E1B4B),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 16,
                                                color: Color(0xFF312E81),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${vm.filteredStudents.length}/$totalSeats Students',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Rows built top-to-bottom with right-to-left, bottom-to-top numbering
                                      Column(
                                        children: List.generate(rowsPerCol, (
                                          rowIndex,
                                        ) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: rowIndex == aisleAfterRow
                                                  ? 16.0
                                                  : 8.0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: List.generate(numCols, (
                                                colIndex,
                                              ) {
                                                final seatNum =
                                                    _seatNumberAtGridPosition(
                                                      rowFromTop: rowIndex,
                                                      colFromLeft: colIndex,
                                                      rowsPerCol: rowsPerCol,
                                                      startSeat: totalStart,
                                                    );

                                                if (seatNum > totalEnd) {
                                                  return const Expanded(
                                                    child: SizedBox(),
                                                  );
                                                }

                                                final assignment = vm
                                                    .getAssignmentForSeat(
                                                      seatNum,
                                                    );

                                                // Hide seats outside user's assigned zones when in ASSIGNED ZONE or Invigilator mode
                                                if (isMyZoneMode &&
                                                    (assignment == null ||
                                                        assignment
                                                                .collectorStaffId !=
                                                            vm
                                                                .currentUser
                                                                .staffId)) {
                                                  return const Expanded(
                                                    child: SizedBox(),
                                                  );
                                                }

                                                final student = vm
                                                    .getStudentAtSeat(seatNum);

                                                Color avatarFill = const Color(
                                                  0xFFD1D5DB,
                                                );
                                                Color badgeFill = const Color(
                                                  0xFFE5E7EB,
                                                );

                                                if (assignment != null) {
                                                  final cIdx = vm
                                                      .getAssignmentColorIndex(
                                                        assignment,
                                                      );
                                                  avatarFill =
                                                      _zoneCardColors[cIdx %
                                                          _zoneCardColors
                                                              .length];
                                                  badgeFill =
                                                      _zoneCardColors[cIdx %
                                                          _zoneCardColors
                                                              .length];
                                                } else if (student != null) {
                                                  final isAbsent =
                                                      student.attendanceStatus
                                                          .toLowerCase() ==
                                                      'absent';
                                                  avatarFill = isAbsent
                                                      ? const Color(0xFFF87171)
                                                      : const Color(0xFF6EE7B7);
                                                  badgeFill = isAbsent
                                                      ? const Color(0xFFF87171)
                                                      : const Color(0xFF6EE7B7);
                                                }

                                                return Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if (assignment != null) {
                                                        vm.selectAssignmentBySeat(
                                                          seatNum,
                                                        );
                                                      }
                                                      _showStudentSeatPopup(
                                                        student,
                                                        seatNum,
                                                      );
                                                    },
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 18,
                                                          height: 18,
                                                          decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: avatarFill,
                                                            border: Border.all(
                                                              color:
                                                                  const Color(
                                                                    0xFF111827,
                                                                  ),
                                                              width: 1.3,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 7,
                                                                vertical: 2,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: badgeFill,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4,
                                                                ),
                                                            border: Border.all(
                                                              color:
                                                                  const Color(
                                                                    0xFF111827,
                                                                  ),
                                                              width: 1.3,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'S${seatNum.toString().padLeft(2, '0')}',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                    0xFF111827,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Selected Collector Detail Card
                              if (vm.selectedAssignment != null)
                                _CollectorDetailCard(
                                  assignment: vm.selectedAssignment!,
                                  exam: exam,
                                  cardColor:
                                      _zoneCardColors[vm
                                              .getAssignmentColorIndex(
                                                vm.selectedAssignment!,
                                              ) %
                                          _zoneCardColors.length],
                                  canManage: vm.isLeadInvigilator,
                                  onEdit: () =>
                                      _navigateToEdit(vm.selectedAssignment!),
                                  onDelete: () =>
                                      _confirmDelete(vm.selectedAssignment!),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    vm.isLeadInvigilator
                                        ? 'No collection zones assigned yet. Tap "Assign" above to allocate seat ranges.'
                                        : 'No collection zone has been assigned to you yet.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
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
          ),
        );
      },
    );
  }
}

class _SectionFilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SectionFilterPill({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : const Color(0xFF1E1B4B),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF1E1B4B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionChipButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.white54 : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF1E1B4B)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorDetailCard extends StatelessWidget {
  final CollectionAreaAssignment assignment;
  final ExamSessionInfo? exam;
  final Color cardColor;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CollectorDetailCard({
    required this.assignment,
    required this.exam,
    required this.cardColor,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1B4B), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.person_outline, color: Color(0xFF1E1B4B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.collectorName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'StaffID ${assignment.collectorStaffId} • ${assignment.collectorRole}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Text(
                      'Seat: ${assignment.formattedRange}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ],
                ),
              ),
              if (canManage)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.errorRed,
                  ),
                  tooltip: 'Remove Assignment',
                ),
            ],
          ),
          const Divider(height: 16, color: Colors.black26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam?.courseCode ?? assignment.courseCode,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                  Text(
                    '${exam?.courseName.toUpperCase() ?? 'ARTIFICIAL INTELLIGENCE'} (${exam?.time ?? '9.00 am - 12.00 pm'})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              if (canManage)
                InkWell(
                  onTap: onEdit,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
