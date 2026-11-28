import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/staff_user.dart';
import '../models/collection_area_assignment.dart';
import 'collection_assignment_service.dart';

class FirebaseCollectionAssignmentService
    implements CollectionAssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<ExamSessionInfo> fetchExamSession(String examId) async {
    final doc = await _firestore.collection('exams').doc(examId).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Exam session "$examId" was not found in Firebase.');
    }
    return ExamSessionInfo.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<List<SeatStudent>> fetchExamStudents(String examId) async {
    final snap = await _firestore
        .collection('student')
        .where('examID', isEqualTo: examId)
        .get();

    final students = snap.docs
        .map((doc) => SeatStudent.fromMap(doc.data(), doc.id))
        .toList();
    students.sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
    return students;
  }

  @override
  Future<List<StaffUser>> fetchHallStaff(List<String> staffIds) async {
    if (staffIds.isEmpty) return [];
    final snap = await _firestore.collection('account').get();
    final staffList = snap.docs
        .map((doc) => StaffUser.fromMap(doc.data(), doc.id))
        .where(
          (user) =>
              staffIds.contains(user.staffId) || staffIds.contains(user.docId),
        )
        .toList();
    return staffList;
  }

  @override
  Future<List<CollectionAreaAssignment>> fetchAssignments({
    required String examId,
    required StaffUser currentUser,
  }) async {
    final roleLower = currentUser.role.toLowerCase();
    final isSupervisor =
        roleLower == 'admin' || roleLower == 'lead invigilator';

    final snap = isSupervisor
        ? await _firestore
              .collection('collection_assignments')
              .where('examID', isEqualTo: examId)
              .get()
        : await _firestore
              .collection('collection_assignments')
              .where('examID', isEqualTo: examId)
              .where('collectorStaffID', isEqualTo: currentUser.staffId)
              .get();

    final list = snap.docs
        .map((doc) => CollectionAreaAssignment.fromMap(doc.data(), doc.id))
        .where((item) => item.collectorStaffId.isNotEmpty && item.seatStart > 0)
        .toList();

    list.sort((a, b) => a.seatStart.compareTo(b.seatStart));
    return list;
  }

  @override
  Future<void> createAssignment(CollectionAreaAssignment assignment) async {
    await _firestore
        .collection('collection_assignments')
        .add(assignment.toMap());
  }

  @override
  Future<void> updateAssignment({
    required String assignmentId,
    required int seatStart,
    required int seatEnd,
    required StaffUser newCollector,
    required String updatedByStaffId,
  }) async {
    await _firestore
        .collection('collection_assignments')
        .doc(assignmentId)
        .update({
          'seatStart': seatStart,
          'seatEnd': seatEnd,
          'collectorStaffID': newCollector.staffId,
          'collectorName': newCollector.name,
          'collectorRole': newCollector.role,
          'assignedByStaffID': updatedByStaffId,
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  @override
  Future<void> mergeAssignments({
    required String targetAssignmentId,
    required int mergedSeatStart,
    required int mergedSeatEnd,
    required StaffUser collector,
    required String updatedByStaffId,
    String? redundantAssignmentId,
  }) async {
    final batch = _firestore.batch();
    final col = _firestore.collection('collection_assignments');

    batch.update(col.doc(targetAssignmentId), {
      'seatStart': mergedSeatStart,
      'seatEnd': mergedSeatEnd,
      'collectorStaffID': collector.staffId,
      'collectorName': collector.name,
      'collectorRole': collector.role,
      'assignedByStaffID': updatedByStaffId,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    if (redundantAssignmentId != null &&
        redundantAssignmentId != targetAssignmentId) {
      batch.delete(col.doc(redundantAssignmentId));
    }

    await batch.commit();
  }

  @override
  Future<void> swapAssignmentCollectors({
    required CollectionAreaAssignment first,
    required CollectionAreaAssignment second,
    required String updatedByStaffId,
  }) async {
    final docA = _firestore.collection('collection_assignments').doc(first.id);
    final docB = _firestore.collection('collection_assignments').doc(second.id);
    final now = DateTime.now().toIso8601String();

    await _firestore.runTransaction((tx) async {
      tx.update(docA, {
        'collectorStaffID': second.collectorStaffId,
        'collectorName': second.collectorName,
        'collectorRole': second.collectorRole,
        'assignedByStaffID': updatedByStaffId,
        'updatedAt': now,
      });
      tx.update(docB, {
        'collectorStaffID': first.collectorStaffId,
        'collectorName': first.collectorName,
        'collectorRole': first.collectorRole,
        'assignedByStaffID': updatedByStaffId,
        'updatedAt': now,
      });
    });
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    await _firestore
        .collection('collection_assignments')
        .doc(assignmentId)
        .delete();
  }
}
