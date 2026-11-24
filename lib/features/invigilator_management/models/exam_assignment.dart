class ExamAssignment {
  final String docId;
  final String invigilatorDocId;
  final String invigilatorName;
  final String invigilatorStaffId;
  final String examName;
  final String status;

  ExamAssignment({
    required this.docId,
    required this.invigilatorDocId,
    required this.invigilatorName,
    required this.invigilatorStaffId,
    required this.examName,
    this.status = 'active',
  });

  factory ExamAssignment.fromMap(Map<String, dynamic> map, String docId) {
    return ExamAssignment(
      docId: docId,
      invigilatorDocId: (map['invigilatorDocId'] ?? '').toString(),
      invigilatorName: (map['invigilatorName'] ?? 'Unknown').toString(),
      invigilatorStaffId: (map['invigilatorStaffId'] ?? '-').toString(),
      examName: (map['examName'] ?? '-').toString(),
      status: (map['status'] ?? 'active').toString(),
    );
  }
}
