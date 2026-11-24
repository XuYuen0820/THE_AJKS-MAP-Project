import '../../../core/models/staff_user.dart';
import '../models/exam_assignment.dart';

abstract class InvigilatorService {
  Stream<List<StaffUser>> streamInvigilators();
  Stream<List<StaffUser>> streamActiveInvigilators();
  Stream<List<ExamAssignment>> streamAssignments();
  Future<void> assignInvigilator({
    required StaffUser invigilator,
    required String examName,
  });
  Future<void> dischargeInvigilator(String assignmentDocId);
}
