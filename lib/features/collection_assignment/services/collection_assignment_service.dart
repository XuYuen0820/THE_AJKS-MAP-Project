import '../../../core/models/staff_user.dart';
import '../models/collection_area_assignment.dart';

abstract class CollectionAssignmentService {
  Future<ExamSessionInfo> fetchExamSession(String examId);
  Future<List<SeatStudent>> fetchExamStudents(String examId);
  Future<List<StaffUser>> fetchHallStaff(List<String> staffIds);
  Future<List<CollectionAreaAssignment>> fetchAssignments({
    required String examId,
    required StaffUser currentUser,
  });
  Future<void> createAssignment(CollectionAreaAssignment assignment);
  Future<void> updateAssignment({
    required String assignmentId,
    required int seatStart,
    required int seatEnd,
    required StaffUser newCollector,
    required String updatedByStaffId,
  });
  Future<void> mergeAssignments({
    required String targetAssignmentId,
    required int mergedSeatStart,
    required int mergedSeatEnd,
    required StaffUser collector,
    required String updatedByStaffId,
    String? redundantAssignmentId,
  });
  Future<void> swapAssignmentCollectors({
    required CollectionAreaAssignment first,
    required CollectionAreaAssignment second,
    required String updatedByStaffId,
  });
  Future<void> deleteAssignment(String assignmentId);
}
