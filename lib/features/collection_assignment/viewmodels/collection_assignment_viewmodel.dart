import 'package:flutter/foundation.dart';

import '../../../core/models/staff_user.dart';
import '../models/collection_area_assignment.dart';
import '../services/collection_assignment_service.dart';

class CollectionAssignmentViewModel extends ChangeNotifier {
  final CollectionAssignmentService _service;

  CollectionAssignmentViewModel(this._service);

  late StaffUser currentUser;
  String examId = 'exam001';

  ExamSessionInfo? examInfo;
  List<SeatStudent> students = [];
  List<StaffUser> hallStaff = [];
  List<CollectionAreaAssignment> assignments = [];
  CollectionAreaAssignment? selectedAssignment;

  String selectedSection = 'ALL';
  bool isLoading = false;
  String? errorMessage;

  bool get isLeadInvigilator =>
      currentUser.role.trim().toLowerCase() == 'lead invigilator';

  bool get isAdmin => currentUser.role.trim().toLowerCase() == 'admin';

  bool get isSupervisor => isLeadInvigilator || isAdmin;

  /// Assignments belonging to the currently logged-in user
  List<CollectionAreaAssignment> get myAssignments {
    return assignments
        .where((a) => a.collectorStaffId == currentUser.staffId)
        .toList();
  }

  /// Extracts available sections (e.g. ['5', '6']) from examInfo and students
  List<String> get availableSections {
    final set = <String>{};
    if (examInfo != null && examInfo!.section.isNotEmpty) {
      for (final part in examInfo!.section.split(',')) {
        final clean = part.trim();
        if (clean.isNotEmpty) set.add(clean);
      }
    }
    for (final s in students) {
      if (s.section.isNotEmpty) set.add(s.section.trim());
    }
    final list = set.toList()..sort();
    return list;
  }

  /// Students filtered by role and active section/zone tab
  List<SeatStudent> get filteredStudents {
    if (!isSupervisor || selectedSection == 'MY_ZONE') {
      if (myAssignments.isEmpty) return [];
      return students
          .where((s) => myAssignments.any((a) => a.containsSeat(s.seatNumber)))
          .toList();
    }
    if (selectedSection == 'ALL') return students;
    return students.where((s) => s.section.trim() == selectedSection).toList();
  }

  /// Seat range bounds: Supervisors see full hall/section or their own zone when MY_ZONE is tapped
  int get displaySeatStart {
    if ((!isSupervisor || selectedSection == 'MY_ZONE') &&
        myAssignments.isNotEmpty) {
      return myAssignments
          .map((a) => a.seatStart)
          .reduce((a, b) => a < b ? a : b);
    }
    if (selectedSection != 'ALL' && filteredStudents.isNotEmpty) {
      return filteredStudents
          .map((s) => s.seatNumber)
          .reduce((a, b) => a < b ? a : b);
    }
    return examInfo?.seatStart ?? 1;
  }

  int get displaySeatEnd {
    if ((!isSupervisor || selectedSection == 'MY_ZONE') &&
        myAssignments.isNotEmpty) {
      return myAssignments
          .map((a) => a.seatEnd)
          .reduce((a, b) => a > b ? a : b);
    }
    if (selectedSection != 'ALL' && filteredStudents.isNotEmpty) {
      return filteredStudents
          .map((s) => s.seatNumber)
          .reduce((a, b) => a > b ? a : b);
    }
    if (students.isNotEmpty) {
      final maxStudentSeat = students
          .map((s) => s.seatNumber)
          .reduce((a, b) => a > b ? a : b);
      final examEnd = examInfo?.seatEnd ?? 60;
      return maxStudentSeat > examEnd ? maxStudentSeat : examEnd;
    }
    return examInfo?.seatEnd ?? 60;
  }

  bool isCollectorAssigned(String staffId) {
    return assignments.any((a) => a.collectorStaffId == staffId);
  }

  List<CollectionAreaAssignment> getAssignmentsForCollector(String staffId) {
    return assignments.where((a) => a.collectorStaffId == staffId).toList();
  }

  String getCollectorStatusLabel(String staffId) {
    final zones = getAssignmentsForCollector(staffId);
    if (zones.isEmpty) return 'Unassigned';
    final ranges = zones.map((z) => z.formattedRange).join(', ');
    return 'Assigned ($ranges)';
  }

  void setSectionFilter(String section) {
    selectedSection = section;
    if (section == 'MY_ZONE' && myAssignments.isNotEmpty) {
      selectedAssignment = myAssignments.first;
    }
    notifyListeners();
  }

  void init({required StaffUser user, String targetExamId = 'exam001'}) {
    currentUser = user;
    examId = targetExamId;
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      examInfo = await _service.fetchExamSession(examId);
      students = await _service.fetchExamStudents(examId);
      hallStaff = await _service.fetchHallStaff(examInfo!.assignedStaffIds);
      assignments = await _service.fetchAssignments(
        examId: examId,
        currentUser: currentUser,
      );

      if (selectedAssignment != null) {
        final match = assignments
            .where((a) => a.id == selectedAssignment!.id)
            .toList();
        selectedAssignment = match.isNotEmpty ? match.first : null;
      }
      if (selectedAssignment == null && assignments.isNotEmpty) {
        selectedAssignment = assignments.first;
      }
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectAssignmentBySeat(int seatNumber) {
    final found = getAssignmentForSeat(seatNumber);
    selectedAssignment = found;
    notifyListeners();
  }

  void selectAssignment(CollectionAreaAssignment assignment) {
    selectedAssignment = assignment;
    notifyListeners();
  }

  CollectionAreaAssignment? getAssignmentForSeat(int seatNumber) {
    for (final assignment in assignments) {
      if (assignment.containsSeat(seatNumber)) {
        return assignment;
      }
    }
    return null;
  }

  SeatStudent? getStudentAtSeat(int seatNumber) {
    for (final s in filteredStudents) {
      if (s.seatNumber == seatNumber) return s;
    }
    return null;
  }

  /// Keys color by collectorStaffId so all areas belonging to the same collector share the exact same color
  int getAssignmentColorIndex(CollectionAreaAssignment assignment) {
    final uniqueCollectors = <String>[];
    for (final a in assignments) {
      if (!uniqueCollectors.contains(a.collectorStaffId)) {
        uniqueCollectors.add(a.collectorStaffId);
      }
    }
    final idx = uniqueCollectors.indexOf(assignment.collectorStaffId);
    return idx < 0 ? 0 : idx;
  }

  /// CREATE: Assign seat range (automatically merges if adjacent to collector's existing zone)
  Future<String?> assignCollectionArea({
    required int seatStart,
    required int seatEnd,
    required StaffUser collector,
  }) async {
    if (!isLeadInvigilator) {
      return 'Only Lead Invigilators can assign collection areas.';
    }

    final minSeat = examInfo?.seatStart ?? 1;
    final maxSeat = displaySeatEnd > (examInfo?.seatEnd ?? 60)
        ? displaySeatEnd
        : (examInfo?.seatEnd ?? 60);

    if (seatStart < minSeat || seatEnd > maxSeat || seatStart > seatEnd) {
      return 'Invalid seat range. Please enter seats between $minSeat and $maxSeat.';
    }

    for (final existing in assignments) {
      final overlaps =
          seatStart <= existing.seatEnd && seatEnd >= existing.seatStart;
      if (overlaps) {
        return 'Seats ${existing.formattedRange} are already assigned to ${existing.collectorName}.';
      }
    }

    isLoading = true;
    notifyListeners();

    try {
      final sameCollectorZones = assignments
          .where((a) => a.collectorStaffId == collector.staffId)
          .toList();

      CollectionAreaAssignment? leftAdjacent;
      CollectionAreaAssignment? rightAdjacent;
      for (final z in sameCollectorZones) {
        if (z.seatEnd + 1 == seatStart) leftAdjacent = z;
        if (seatEnd + 1 == z.seatStart) rightAdjacent = z;
      }

      if (leftAdjacent != null || rightAdjacent != null) {
        final mergedStart = leftAdjacent?.seatStart ?? seatStart;
        final mergedEnd = rightAdjacent?.seatEnd ?? seatEnd;
        final targetId = (leftAdjacent ?? rightAdjacent)!.id;
        final redundantId = (leftAdjacent != null && rightAdjacent != null)
            ? rightAdjacent.id
            : null;

        await _service.mergeAssignments(
          targetAssignmentId: targetId,
          mergedSeatStart: mergedStart,
          mergedSeatEnd: mergedEnd,
          collector: collector,
          updatedByStaffId: currentUser.staffId,
          redundantAssignmentId: redundantId,
        );
      } else {
        final newAssignment = CollectionAreaAssignment(
          id: '',
          examId: examId,
          courseCode: examInfo?.courseCode ?? 'SECJ 3553',
          seatStart: seatStart,
          seatEnd: seatEnd,
          collectorStaffId: collector.staffId,
          collectorName: collector.name,
          collectorRole: collector.role,
          assignedByStaffId: currentUser.staffId,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await _service.createAssignment(newAssignment);
      }

      await loadData();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// UPDATE: Edit seat range/collector (merges automatically if collector already owns an adjacent zone)
  Future<String?> updateAssignment({
    required CollectionAreaAssignment assignment,
    required int seatStart,
    required int seatEnd,
    required StaffUser newCollector,
  }) async {
    if (!isLeadInvigilator) {
      return 'Only Lead Invigilators can edit collection areas.';
    }

    final minSeat = examInfo?.seatStart ?? 1;
    final maxSeat = displaySeatEnd > (examInfo?.seatEnd ?? 60)
        ? displaySeatEnd
        : (examInfo?.seatEnd ?? 60);

    if (seatStart < minSeat || seatEnd > maxSeat || seatStart > seatEnd) {
      return 'Invalid seat range. Please enter seats between $minSeat and $maxSeat.';
    }

    for (final existing in assignments) {
      if (existing.id == assignment.id) continue;
      final overlaps =
          seatStart <= existing.seatEnd && seatEnd >= existing.seatStart;
      if (overlaps) {
        return 'Seats ${existing.formattedRange} are already assigned to ${existing.collectorName}.';
      }
    }

    isLoading = true;
    notifyListeners();

    try {
      final otherSameCollectorZones = assignments
          .where(
            (a) =>
                a.id != assignment.id &&
                a.collectorStaffId == newCollector.staffId,
          )
          .toList();

      CollectionAreaAssignment? leftAdjacent;
      CollectionAreaAssignment? rightAdjacent;
      for (final z in otherSameCollectorZones) {
        if (z.seatEnd + 1 == seatStart) leftAdjacent = z;
        if (seatEnd + 1 == z.seatStart) rightAdjacent = z;
      }

      if (leftAdjacent != null || rightAdjacent != null) {
        final mergedStart = leftAdjacent?.seatStart ?? seatStart;
        final mergedEnd = rightAdjacent?.seatEnd ?? seatEnd;
        final primaryNeighbor = leftAdjacent ?? rightAdjacent!;

        await _service.mergeAssignments(
          targetAssignmentId: primaryNeighbor.id,
          mergedSeatStart: mergedStart,
          mergedSeatEnd: mergedEnd,
          collector: newCollector,
          updatedByStaffId: currentUser.staffId,
          redundantAssignmentId: assignment.id,
        );

        if (leftAdjacent != null && rightAdjacent != null) {
          await _service.deleteAssignment(rightAdjacent.id);
        }

        selectedAssignment = null;
      } else {
        await _service.updateAssignment(
          assignmentId: assignment.id,
          seatStart: seatStart,
          seatEnd: seatEnd,
          newCollector: newCollector,
          updatedByStaffId: currentUser.staffId,
        );
      }

      await loadData();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// UPDATE (Swap): Swap collectors between two assigned sections
  Future<String?> swapCollectors({
    required CollectionAreaAssignment first,
    required CollectionAreaAssignment second,
  }) async {
    if (!isLeadInvigilator) {
      return 'Only Lead Invigilators can swap collectors.';
    }
    if (first.id == second.id) {
      return 'Please select two different collection zones to swap.';
    }

    isLoading = true;
    notifyListeners();

    try {
      await _service.swapAssignmentCollectors(
        first: first,
        second: second,
        updatedByStaffId: currentUser.staffId,
      );
      await loadData();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// DELETE: Remove active assignment
  Future<String?> removeAssignment(CollectionAreaAssignment assignment) async {
    if (!isLeadInvigilator) {
      return 'Only Lead Invigilators can remove assignments.';
    }

    isLoading = true;
    notifyListeners();

    try {
      await _service.deleteAssignment(assignment.id);
      if (selectedAssignment?.id == assignment.id) {
        selectedAssignment = null;
      }
      await loadData();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
