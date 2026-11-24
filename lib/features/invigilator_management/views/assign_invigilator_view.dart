import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/exora_logo.dart';
import '../viewmodels/invigilator_management_viewmodel.dart';

class AssignInvigilatorView extends StatefulWidget {
  final InvigilatorManagementViewModel viewModel;

  const AssignInvigilatorView({super.key, required this.viewModel});

  @override
  State<AssignInvigilatorView> createState() => _AssignInvigilatorViewState();
}

class _AssignInvigilatorViewState extends State<AssignInvigilatorView> {
  final _formKey = GlobalKey<FormState>();
  final _examController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.startListeningActiveInvigilators();
  }

  @override
  void dispose() {
    _examController.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await widget.viewModel.assignInvigilator(
      _examController.text,
    );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invigilator assigned successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (widget.viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage!),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final activeList = widget.viewModel.activeInvigilators;

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
                                  if (widget
                                      .viewModel
                                      .isLoadingActiveInvigilators)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: LinearProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    DropdownButtonFormField<String>(
                                      initialValue: widget
                                          .viewModel
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
                                      items: activeList.map((u) {
                                        return DropdownMenuItem<String>(
                                          value: u.staffId,
                                          child: Text(
                                            '${u.name} (${u.staffId})',
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newStaffId) {
                                        final picked = activeList.firstWhere(
                                          (u) => u.staffId == newStaffId,
                                        );
                                        widget.viewModel.selectInvigilator(
                                          picked,
                                        );
                                      },
                                      validator: (v) =>
                                          v == null ? 'Required' : null,
                                    ),
                                  const SizedBox(height: 28),
                                  ElevatedButton(
                                    onPressed: widget.viewModel.isSubmitting
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
                                    child: widget.viewModel.isSubmitting
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
