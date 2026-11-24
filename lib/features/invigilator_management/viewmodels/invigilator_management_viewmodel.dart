import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/staff_user.dart';
import '../models/exam_assignment.dart';
import '../services/invigilator_service.dart';

class InvigilatorManagementViewModel extends ChangeNotifier {
  final InvigilatorService _service;

  StreamSubscription<List<StaffUser>>? _invigilatorsSub;
  StreamSubscription<List<StaffUser>>? _activeInvigilatorsSub;
  StreamSubscription<List<ExamAssignment>>? _assignmentsSub;

  List<StaffUser> invigilators = [];
  List<StaffUser> activeInvigilators = [];
  List<ExamAssignment> assignments = [];

  bool isLoadingInvigilators = true;
  bool isLoadingActiveInvigilators = true;
  bool isLoadingAssignments = true;
  bool isSubmitting = false;

  String? errorMessage;
  StaffUser? _selectedInvigilator;

  StaffUser? get selectedInvigilator => _selectedInvigilator;

  InvigilatorManagementViewModel(this._service);

  void startListeningInvigilators() {
    isLoadingInvigilators = true;
    _invigilatorsSub?.cancel();
    _invigilatorsSub = _service.streamInvigilators().listen(
      (list) {
        invigilators = list;
        isLoadingInvigilators = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        errorMessage = 'Failed to load invigilators: $e';
        isLoadingInvigilators = false;
        notifyListeners();
      },
    );
  }

  void startListeningActiveInvigilators() {
    isLoadingActiveInvigilators = true;
    _activeInvigilatorsSub?.cancel();
    _activeInvigilatorsSub = _service.streamActiveInvigilators().listen(
      (list) {
        activeInvigilators = list;
        isLoadingActiveInvigilators = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        errorMessage = 'Failed to load active invigilators: $e';
        isLoadingActiveInvigilators = false;
        notifyListeners();
      },
    );
  }

  void startListeningAssignments() {
    isLoadingAssignments = true;
    _assignmentsSub?.cancel();
    _assignmentsSub = _service.streamAssignments().listen(
      (list) {
        assignments = list;
        isLoadingAssignments = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        errorMessage = 'Failed to load assignments: $e';
        isLoadingAssignments = false;
        notifyListeners();
      },
    );
  }

  void selectInvigilator(StaffUser? user) {
    _selectedInvigilator = user;
    notifyListeners();
  }

  Future<bool> assignInvigilator(String examName) async {
    if (_selectedInvigilator == null) {
      errorMessage = 'Please select an invigilator.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.assignInvigilator(
        invigilator: _selectedInvigilator!,
        examName: examName,
      );
      return true;
    } catch (e) {
      errorMessage = 'Failed to assign invigilator: $e';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> dischargeInvigilator(String assignmentDocId) async {
    errorMessage = null;
    try {
      await _service.dischargeInvigilator(assignmentDocId);
      return true;
    } catch (e) {
      errorMessage = 'Failed to discharge invigilator: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _invigilatorsSub?.cancel();
    _activeInvigilatorsSub?.cancel();
    _assignmentsSub?.cancel();
    super.dispose();
  }
}
