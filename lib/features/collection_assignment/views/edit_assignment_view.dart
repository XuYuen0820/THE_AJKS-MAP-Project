import 'package:flutter/material.dart';

import '../../../core/models/staff_user.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/exora_logo.dart';
import '../models/collection_area_assignment.dart';
import '../viewmodels/collection_assignment_viewmodel.dart';

class EditAssignmentView extends StatefulWidget {
  final CollectionAssignmentViewModel viewModel;
  final CollectionAreaAssignment assignment;

  const EditAssignmentView({
    super.key,
    required this.viewModel,
    required this.assignment,
  });

  @override
  State<EditAssignmentView> createState() => _EditAssignmentViewState();
}

class _EditAssignmentViewState extends State<EditAssignmentView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _seatStartController;
  late final TextEditingController _seatEndController;
  String? _selectedCollectorId;

  @override
  void initState() {
    super.initState();
    _seatStartController = TextEditingController(
      text: widget.assignment.seatStart.toString(),
    );
    _seatEndController = TextEditingController(
      text: widget.assignment.seatEnd.toString(),
    );
    _selectedCollectorId = widget.assignment.collectorStaffId;
  }

  @override
  void dispose() {
    _seatStartController.dispose();
    _seatEndController.dispose();
    super.dispose();
  }

  List<StaffUser> _uniqueStaff(List<StaffUser> raw) {
    final seen = <String>{};
    final result = <StaffUser>[];
    for (final s in raw) {
      if (seen.add(s.staffId)) {
        result.add(s);
      }
    }
    return result;
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.errorRed : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onSave(StaffUser? activeCollector) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (activeCollector == null) return;

    final newStart = int.parse(_seatStartController.text.trim());
    final newEnd = int.parse(_seatEndController.text.trim());

    final err = await widget.viewModel.updateAssignment(
      assignment: widget.assignment,
      seatStart: newStart,
      seatEnd: newEnd,
      newCollector: activeCollector,
    );

    if (!mounted) return;
    if (err != null) {
      _showMessage(err, isError: true);
    } else {
      _showMessage('Collection area updated!');
      Navigator.pop(context, true);
    }
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Assignment?'),
        content: Text(
          'Unassign ${widget.assignment.collectorName} from ${widget.assignment.formattedRange}?',
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

    if (confirm != true) return;

    final err = await widget.viewModel.removeAssignment(widget.assignment);
    if (!mounted) return;
    if (err != null) {
      _showMessage(err, isError: true);
    } else {
      _showMessage('Assignment removed.');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final minSeat = vm.examInfo?.seatStart ?? 1;
    final maxSeat = vm.displaySeatEnd > (vm.examInfo?.seatEnd ?? 60)
        ? vm.displaySeatEnd
        : (vm.examInfo?.seatEnd ?? 60);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final staffList = _uniqueStaff(vm.hallStaff);
        StaffUser? activeCollector;
        if (staffList.isNotEmpty) {
          activeCollector = staffList.firstWhere(
            (s) => s.staffId == _selectedCollectorId,
            orElse: () => staffList.first,
          );
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(height: 20),
                          const Text(
                            'EDIT COLLECTION AREA',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Zone ${widget.assignment.formattedRange} • Currently ${widget.assignment.collectorName}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 22),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Seat Range & Collector',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textHeadline,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'Start Seat',
                                        hintText: 'e.g. 1',
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
                                        label: 'End Seat',
                                        hintText: 'e.g. 20',
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
                                const Text(
                                  'Designated Collector',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<StaffUser>(
                                  key: ValueKey(activeCollector?.staffId),
                                  initialValue: activeCollector,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  items: staffList.map((staff) {
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
                                  onChanged: (val) => setState(
                                    () => _selectedCollectorId = val?.staffId,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                CustomButton(
                                  text: 'Save Changes',
                                  isLoading: vm.isLoading,
                                  onPressed: () => _onSave(activeCollector),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: vm.isLoading ? null : _onDelete,
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: const Text(
                                'Remove Assignment',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorRed,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
          ),
        );
      },
    );
  }
}
