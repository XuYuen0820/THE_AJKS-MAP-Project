import 'package:flutter/foundation.dart';

import '../../models/exam_assignment.dart';
import '../../models/staff_user.dart';
import '../../services/invigilator_service.dart';

class InvigilatorManagementViewModel extends ChangeNotifier {
  final InvigilatorService _service;

  InvigilatorManagementViewModel({InvigilatorService? service})
    : _service = service ?? InvigilatorService();

  bool _isSubmitting = false;
  StaffUser? _selectedInvigilator;

  bool get isSubmitting => _isSubmitting;
  StaffUser? get selectedInvigilator => _selectedInvigilator;

  Stream<List<StaffUser>> get invigilatorsStream =>
      _service.streamInvigilators();

  Stream<List<StaffUser>> get activeInvigilatorsStream =>
      _service.streamActiveInvigilators();

  Stream<List<ExamAssignment>> get assignmentsStream =>
      _service.streamAssignments();

  void selectInvigilator(StaffUser? user) {
    _selectedInvigilator = user;
    notifyListeners();
  }

  Future<void> assignInvigilator(String examName) async {
    if (_selectedInvigilator == null) return;
    _isSubmitting = true;
    notifyListeners();

    try {
      await _service.assignInvigilator(
        invigilator: _selectedInvigilator!,
        examName: examName,
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> dischargeInvigilator(String assignmentDocId) async {
    await _service.dischargeInvigilator(assignmentDocId);
  }
}
