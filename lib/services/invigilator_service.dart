import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/exam_assignment.dart';
import '../models/staff_user.dart';

class InvigilatorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Stream<List<StaffUser>> streamActiveInvigilators() {
    return streamInvigilators().map(
      (list) => list.where((u) => u.isActive).toList(),
    );
  }

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

  Future<void> dischargeInvigilator(String assignmentDocId) async {
    await _firestore.collection('assignments').doc(assignmentDocId).delete();
  }
}
