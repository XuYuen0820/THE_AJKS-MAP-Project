import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/staff_user.dart';
import '../models/exam_assignment.dart';
import 'invigilator_service.dart';

class FirebaseInvigilatorService implements InvigilatorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<StaffUser>> streamInvigilators() {
    return _firestore
        .collection('account')
        .where('role', whereIn: ['Invigilator', 'invigilator'])
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StaffUser.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Stream<List<StaffUser>> streamActiveInvigilators() {
    return streamInvigilators().map(
      (list) => list.where((u) => u.isActive).toList(),
    );
  }

  @override
  Stream<List<ExamAssignment>> streamAssignments() {
    return _firestore
        .collection('assignments')
        .orderBy('assignedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExamAssignment.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<void> assignInvigilator({
    required StaffUser invigilator,
    required String examName,
  }) async {
    await _firestore.collection('assignments').add({
      'invigilatorDocId': invigilator.docId,
      'invigilatorName': invigilator.name,
      'invigilatorStaffId': invigilator.staffId,
      'examName': examName.trim(),
      'assignedAt': FieldValue.serverTimestamp(),
      'status': 'active',
    });
  }

  @override
  Future<void> dischargeInvigilator(String assignmentDocId) async {
    await _firestore.collection('assignments').doc(assignmentDocId).delete();
  }
}
