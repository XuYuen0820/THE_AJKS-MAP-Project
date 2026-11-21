import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/staff_user.dart';
import '../../widgets/exora_logo.dart';
import 'invigilator_management_viewmodel.dart';

class AssignInvigilatorView extends StatefulWidget {
  const AssignInvigilatorView({super.key});

  @override
  State<AssignInvigilatorView> createState() => _AssignInvigilatorViewState();
}

class _AssignInvigilatorViewState extends State<AssignInvigilatorView> {
  final _formKey = GlobalKey<FormState>();
  final _examController = TextEditingController();
  final _viewModel = InvigilatorManagementViewModel();

  @override
  void dispose() {
    _examController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_viewModel.selectedInvigilator == null) return;

    try {
      await _viewModel.assignInvigilator(_examController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invigilator assigned successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              const ExoraLogo(
                                mainAxisAlignment: MainAxisAlignment.start,
                                iconSize: 24,
                                textHeight: 16,
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Text(
                            'Assign Invigilator',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _examController,
                                    decoration: InputDecoration(
                                      labelText: 'Exam Name / Session',
                                      filled: true,
                                      fillColor: AppColors.cardBackground,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Required'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  StreamBuilder<List<StaffUser>>(
                                    stream: _viewModel.activeInvigilatorsStream,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: LinearProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        );
                                      }
                                      final list = snapshot.data!;
                                      return DropdownButtonFormField<String>(
                                        initialValue: _viewModel
                                            .selectedInvigilator
                                            ?.staffId,
                                        decoration: InputDecoration(
                                          labelText: 'Select Invigilator',
                                          filled: true,
                                          fillColor: AppColors.cardBackground,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        items: list.map((u) {
                                          return DropdownMenuItem<String>(
                                            value: u.staffId,
                                            child: Text(
                                              '${u.name} (${u.staffId})',
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newStaffId) {
                                          final picked = list.firstWhere(
                                            (u) => u.staffId == newStaffId,
                                          );
                                          _viewModel.selectInvigilator(picked);
                                        },
                                        validator: (v) =>
                                            v == null ? 'Required' : null,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 28),
                                  ElevatedButton(
                                    onPressed: _viewModel.isSubmitting
                                        ? null
                                        : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _viewModel.isSubmitting
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Confirm Assignment',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
