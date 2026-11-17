import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../models/staff_user.dart';
import '../../widgets/exora_logo.dart';

class AssignInvigilatorPage extends StatefulWidget {
  const AssignInvigilatorPage({super.key});

  @override
  State<AssignInvigilatorPage> createState() => _AssignInvigilatorPageState();
}

class _AssignInvigilatorPageState extends State<AssignInvigilatorPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStaffId;
  StaffUser? _selectedUser;
  final _examController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _examController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUser == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('assignments').add({
        'invigilatorDocId': _selectedUser!.docId,
        'invigilatorName': _selectedUser!.name,
        'invigilatorStaffId': _selectedUser!.staffId,
        'examName': _examController.text.trim(),
        'assignedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invigilator assigned successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.errorRed),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
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

                    // Page Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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

                    // Form Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),

                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('account')
                                    .doc('staff')
                                    .collection('users')
                                    .where('role', whereIn: ['Invigilator', 'invigilator'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: LinearProgressIndicator(color: Colors.white),
                                    );
                                  }
                                  
                                  final list = snapshot.data!.docs
                                      .map((d) => StaffUser.fromMap(d.data() as Map<String, dynamic>, d.id))
                                      .where((u) => u.isActive)
                                      .toList();

                                  return DropdownButtonFormField<String>(
                                    value: _selectedStaffId,
                                    decoration: InputDecoration(
                                      labelText: 'Select Invigilator',
                                      filled: true,
                                      fillColor: AppColors.cardBackground,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    items: list.map((u) {
                                      return DropdownMenuItem<String>(
                                        value: u.staffId,
                                        child: Text('${u.name} (${u.staffId})'),
                                      );
                                    }).toList(),
                                    onChanged: (String? newStaffId) {
                                      setState(() {
                                        _selectedStaffId = newStaffId;
                                        _selectedUser = list.firstWhere((u) => u.staffId == newStaffId);
                                      });
                                    },
                                    validator: (v) => v == null ? 'Required' : null,
                                  );
                                },
                              ),
                              const SizedBox(height: 28),

                              ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Confirm Assignment',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
  }
}