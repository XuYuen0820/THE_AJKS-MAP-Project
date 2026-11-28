class ExamSessionInfo {
  final String examId;
  final String courseCode;
  final String courseName;
  final String date;
  final String time;
  final String venue;
  final String section;
  final int seatStart;
  final int seatEnd;
  final List<String> assignedStaffIds;

  ExamSessionInfo({
    required this.examId,
    required this.courseCode,
    required this.courseName,
    required this.date,
    required this.time,
    required this.venue,
    required this.section,
    required this.seatStart,
    required this.seatEnd,
    required this.assignedStaffIds,
  });

  factory ExamSessionInfo.fromMap(Map<String, dynamic> map, String docId) {
    return ExamSessionInfo(
      examId: (map['examID'] ?? docId).toString().trim(),
      courseCode: (map['courseCode'] ?? '').toString().trim(),
      courseName: (map['courseName'] ?? '').toString().trim(),
      date: (map['date'] ?? '').toString().trim(),
      time: (map['time'] ?? '').toString().trim(),
      venue: (map['venue'] ?? 'Dewan Sultan Iskandar').toString().trim(),
      section: (map['section'] ?? '').toString().trim(),
      seatStart: (map['seatStart'] as num?)?.toInt() ?? 1,
      seatEnd: (map['seatEnd'] as num?)?.toInt() ?? 60,
      assignedStaffIds: List<String>.from(map['assignedStaffIDs'] ?? []),
    );
  }
}

class SeatStudent {
  final String docId;
  final String examId;
  final int seatNumber;
  final String matricNo;
  final String studentName;
  final String section;
  final String attendanceStatus;
  final bool scriptCollected;

  SeatStudent({
    required this.docId,
    required this.examId,
    required this.seatNumber,
    required this.matricNo,
    required this.studentName,
    required this.section,
    required this.attendanceStatus,
    required this.scriptCollected,
  });

  String get formattedSeat => 'S${seatNumber.toString().padLeft(2, '0')}';

  factory SeatStudent.fromMap(Map<String, dynamic> map, String docId) {
    return SeatStudent(
      docId: docId,
      examId: (map['examID'] ?? '').toString().trim(),
      seatNumber: (map['seatNumber'] as num?)?.toInt() ?? 0,
      matricNo: (map['matricNo'] ?? '').toString().trim(),
      studentName: (map['studentName'] ?? '').toString().trim(),
      section: (map['section'] ?? '').toString().trim(),
      attendanceStatus: (map['attendanceStatus'] ?? 'Absent').toString().trim(),
      scriptCollected: map['scriptCollected'] == true,
    );
  }
}

class CollectionAreaAssignment {
  final String id;
  final String examId;
  final String courseCode;
  final int seatStart;
  final int seatEnd;
  final String collectorStaffId;
  final String collectorName;
  final String collectorRole;
  final String assignedByStaffId;
  final String updatedAt;

  CollectionAreaAssignment({
    required this.id,
    required this.examId,
    required this.courseCode,
    required this.seatStart,
    required this.seatEnd,
    required this.collectorStaffId,
    required this.collectorName,
    required this.collectorRole,
    required this.assignedByStaffId,
    required this.updatedAt,
  });

  String get formattedRange =>
      'S${seatStart.toString().padLeft(2, '0')}–S${seatEnd.toString().padLeft(2, '0')}';

  bool containsSeat(int seat) => seat >= seatStart && seat <= seatEnd;

  factory CollectionAreaAssignment.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return CollectionAreaAssignment(
      id: docId,
      examId: (map['examID'] ?? '').toString().trim(),
      courseCode: (map['courseCode'] ?? '').toString().trim(),
      seatStart: (map['seatStart'] as num?)?.toInt() ?? 0,
      seatEnd: (map['seatEnd'] as num?)?.toInt() ?? 0,
      collectorStaffId: (map['collectorStaffID'] ?? '').toString().trim(),
      collectorName: (map['collectorName'] ?? '').toString().trim(),
      collectorRole: (map['collectorRole'] ?? '').toString().trim(),
      assignedByStaffId: (map['assignedByStaffID'] ?? '').toString().trim(),
      updatedAt: (map['updatedAt'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examID': examId,
      'courseCode': courseCode,
      'seatStart': seatStart,
      'seatEnd': seatEnd,
      'collectorStaffID': collectorStaffId,
      'collectorName': collectorName,
      'collectorRole': collectorRole,
      'assignedByStaffID': assignedByStaffId,
      'updatedAt': updatedAt,
    };
  }
}
