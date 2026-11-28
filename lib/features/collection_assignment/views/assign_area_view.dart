import 'package:flutter/material.dart';

import '../../../core/models/staff_user.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/exora_logo.dart';
import '../viewmodels/collection_assignment_viewmodel.dart';

class AssignAreaView extends StatefulWidget {
  final CollectionAssignmentViewModel viewModel;

  const AssignAreaView({super.key, required this.viewModel});

  @override
  State<AssignAreaView> createState() => _AssignAreaViewState();
}

class _AssignAreaViewState extends State<AssignAreaView> {
  final _formKey = GlobalKey<FormState>();
  final _seatStartController = TextEditingController();
  final _seatEndController = TextEditingController();
  StaffUser? _selectedCollector;

  @override
  void initState() {
    super.initState();
    final sorted = _sortedStaffList();
    if (sorted.isNotEmpty) {
      _selectedCollector = sorted.first;
    }
    _prefillNextStartSeat();
  }

  /// Places Unassigned (available) staff first, followed by Assigned staff
  List<StaffUser> _sortedStaffList() {
    final list = List<StaffUser>.from(widget.viewModel.hallStaff);
    list.sort((a, b) {
      final aAssigned = widget.viewModel.isCollectorAssigned(a.staffId);
      final bAssigned = widget.viewModel.isCollectorAssigned(b.staffId);
      if (aAssigned == bAssigned) return 0;
      return aAssigned ? 1 : -1;
    });
    return list;
  }

  void _prefillNextStartSeat() {
    final minSeat = widget.viewModel.displaySeatStart;
    final maxSeat = widget.viewModel.displaySeatEnd;
    for (int s = minSeat; s <= maxSeat; s++) {
      if (widget.viewModel.getAssignmentForSeat(s) == null) {
        _seatStartController.text = s.toString();
        _seatEndController.clear();
        return;
      }
    }
    _seatStartController.clear();
    _seatEndController.clear();
  }

  @override
  void dispose() {
    _seatStartController.dispose();
    _seatEndController.dispose();
    super.dispose();
  }

  /// 5 columns, right-to-left columns, bottom-to-top rows (Figma layout)
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

  void _onSeatTapped(int seatNum) {
    final existing = widget.viewModel.getAssignmentForSeat(seatNum);
    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Seat S${seatNum.toString().padLeft(2, '0')} is already assigned to ${existing.collectorName}.',
          ),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final currentStart = int.tryParse(_seatStartController.text.trim());
    final currentEnd = int.tryParse(_seatEndController.text.trim());

    setState(() {
      if (currentStart == null || currentEnd != null) {
        _seatStartController.text = seatNum.toString();
        _seatEndController.clear();
      } else if (seatNum >= currentStart) {
        _seatEndController.text = seatNum.toString();
      } else {
        _seatEndController.text = currentStart.toString();
        _seatStartController.text = seatNum.toString();
      }
    });
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCollector == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a collector.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final start = int.parse(_seatStartController.text.trim());
    final end = int.parse(_seatEndController.text.trim());

    final error = await widget.viewModel.assignCollectionArea(
      seatStart: start,
      seatEnd: end,
      collector: _selectedCollector!,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Collection area assigned successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final exam = vm.examInfo;
        final minSeat = vm.displaySeatStart;
        final maxSeat = vm.displaySeatEnd;
        final totalSeats = ((maxSeat - minSeat) + 1).clamp(1, 300);

        const int numCols = 5;
        final int rowsPerCol = (totalSeats / numCols).ceil();
        final int aisleAfterRow = (rowsPerCol * 0.625).round() - 1;

        final previewStart = int.tryParse(_seatStartController.text.trim());
        final previewEnd = int.tryParse(_seatEndController.text.trim());
        final sortedStaff = _sortedStaffList();
        final unassignedCount = sortedStaff
            .where((s) => !vm.isCollectorAssigned(s.staffId))
            .length;

        // Ensure selected value exists in sortedStaff
        final activeCollector = sortedStaff.contains(_selectedCollector)
            ? _selectedCollector
            : (sortedStaff.isNotEmpty ? sortedStaff.first : null);

        final sectionTitle = vm.selectedSection == 'ALL'
            ? 'Section ${exam?.section ?? '5, 6'}'
            : 'Section ${vm.selectedSection}';

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 36),
                                ),
                                child: const Text(
                                  '< Back',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const ExoraLogo(iconSize: 22, textHeight: 15),
                              const SizedBox(width: 50),
                            ],
                          ),
                          const SizedBox(height: 14),

                          const Text(
                            'ASSIGN COLLECTION AREA',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${exam?.courseCode ?? 'SECJ 3553'} • $sectionTitle (S${minSeat.toString().padLeft(2, '0')}–S${maxSeat.toString().padLeft(2, '0')})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Section Filter Pills
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _AssignSectionPill(
                                  label: 'ALL',
                                  isSelected: vm.selectedSection == 'ALL',
                                  onTap: () {
                                    vm.setSectionFilter('ALL');
                                    setState(() => _prefillNextStartSeat());
                                  },
                                ),
                                const SizedBox(width: 8),
                                ...vm.availableSections.map((sec) {
                                  final padded = sec.padLeft(2, '0');
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _AssignSectionPill(
                                      label: 'SEC $padded',
                                      isSelected: vm.selectedSection == sec,
                                      onTap: () {
                                        vm.setSectionFilter(sec);
                                        setState(() => _prefillNextStartSeat());
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Assignment Input Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'Start Seat ($minSeat–$maxSeat)',
                                        hintText: 'e.g. $minSeat',
                                        controller: _seatStartController,
                                        keyboardType: TextInputType.number,
                                        validator: (val) {
                                          final n = int.tryParse(
                                            val?.trim() ?? '',
                                          );
                                          if (n == null) return 'Required';
                                          if (n < minSeat || n > maxSeat) {
                                            return '$minSeat–$maxSeat';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'End Seat ($minSeat–$maxSeat)',
                                        hintText: 'e.g. ${minSeat + 19}',
                                        controller: _seatEndController,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        validator: (val) {
                                          final end = int.tryParse(
                                            val?.trim() ?? '',
                                          );
                                          final start = int.tryParse(
                                            _seatStartController.text.trim(),
                                          );
                                          if (end == null) return 'Required';
                                          if (end < minSeat || end > maxSeat) {
                                            return '$minSeat–$maxSeat';
                                          }
                                          if (start != null && end < start) {
                                            return '>= Start';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Designated Collector Header + Unassigned Count Badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Designated Collector',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: unassignedCount > 0
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$unassignedCount Unassigned',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: unassignedCount > 0
                                              ? const Color(0xFF166534)
                                              : const Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Collector Dropdown with Assigned / Unassigned Pills
                                DropdownButtonFormField<StaffUser>(
                                  initialValue: activeCollector,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.inputBorder,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.inputBorder,
                                      ),
                                    ),
                                  ),
                                  items: sortedStaff.map((staff) {
                                    final isAssigned = vm.isCollectorAssigned(
                                      staff.staffId,
                                    );
                                    final statusLabel = vm
                                        .getCollectorStatusLabel(staff.staffId);

                                    return DropdownMenuItem(
                                      value: staff,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${staff.name} (${staff.role})',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isAssigned
                                                  ? const Color(0xFFFEF3C7)
                                                  : const Color(0xFFDCFCE7),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isAssigned
                                                    ? const Color(0xFFD97706)
                                                    : const Color(0xFF16A34A),
                                              ),
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isAssigned
                                                    ? const Color(0xFF92400E)
                                                    : const Color(0xFF166534),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedCollector = val),
                                ),
                                const SizedBox(height: 18),

                                CustomButton(
                                  text: 'Assign',
                                  isLoading: vm.isLoading,
                                  onPressed: _onSubmit,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Interactive Seat Grid
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
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      sectionTitle,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E1B4B),
                                      ),
                                    ),
                                    const Row(
                                      children: [
                                        _LegendDot(
                                          color: Color(0xFF86EFAC),
                                          label: 'Selected',
                                        ),
                                        SizedBox(width: 8),
                                        _LegendDot(
                                          color: Color(0xFFD9D6FE),
                                          label: 'Assigned',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

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
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(numCols, (
                                          colIndex,
                                        ) {
                                          final seatNum =
                                              _seatNumberAtGridPosition(
                                                rowFromTop: rowIndex,
                                                colFromLeft: colIndex,
                                                rowsPerCol: rowsPerCol,
                                                startSeat: minSeat,
                                              );

                                          if (seatNum > maxSeat) {
                                            return const Expanded(
                                              child: SizedBox(),
                                            );
                                          }

                                          final existingAssignment = vm
                                              .getAssignmentForSeat(seatNum);
                                          final isTaken =
                                              existingAssignment != null;

                                          final isPreviewSelected =
                                              !isTaken &&
                                              previewStart != null &&
                                              ((previewEnd != null &&
                                                      seatNum >= previewStart &&
                                                      seatNum <= previewEnd) ||
                                                  (previewEnd == null &&
                                                      seatNum == previewStart));

                                          Color fill = const Color(0xFFF3F4F6);
                                          if (isTaken) {
                                            fill = const Color(0xFFD9D6FE);
                                          } else if (isPreviewSelected) {
                                            fill = const Color(0xFF86EFAC);
                                          }

                                          return Expanded(
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _onSeatTapped(seatNum),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 18,
                                                    height: 18,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: fill,
                                                      border: Border.all(
                                                        color: isTaken
                                                            ? Colors.grey
                                                            : const Color(
                                                                0xFF111827,
                                                              ),
                                                        width: 1.3,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 7,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: fill,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      border: Border.all(
                                                        color: isTaken
                                                            ? Colors.grey
                                                            : const Color(
                                                                0xFF111827,
                                                              ),
                                                        width: 1.3,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'S${seatNum.toString().padLeft(2, '0')}',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isTaken
                                                            ? Colors.black54
                                                            : const Color(
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
                          const SizedBox(height: 16),
                        ],
                      ),
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

class _AssignSectionPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AssignSectionPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF1E1B4B),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.black54, width: 0.8),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
