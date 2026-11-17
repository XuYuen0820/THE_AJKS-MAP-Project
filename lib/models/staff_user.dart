class StaffUser {
  final String docId;
  final String staffId;
  final String name;
  final String email;
  final String role;
  final String faculty;
  final String passwordHash;
  final bool isActive;
  final String? lastLoginAt;
  final String?
  avatarPath; // Holds either a local file path or Firestore Base64 string

  StaffUser({
    required this.docId,
    required this.staffId,
    required this.name,
    required this.email,
    required this.role,
    required this.faculty,
    required this.passwordHash,
    this.isActive = true,
    this.lastLoginAt,
    this.avatarPath,
  });

  factory StaffUser.fromMap(Map<String, dynamic> map, String docId) {
    return StaffUser(
      docId: docId,
      staffId: (map['staffId'] ?? docId).toString().trim(),
      name: (map['name'] ?? '').toString().trim(),
      email: (map['email'] ?? '').toString().trim(),
      role: (map['role'] ?? 'Invigilator').toString().trim(),
      // Handles both 'Faculty' (capital F in Firestore) and 'faculty' and trims leading spaces
      faculty: (map['Faculty'] ?? map['faculty'] ?? '').toString().trim(),
      passwordHash: (map['passwordHash'] ?? '').toString(),
      isActive: map['isActive'] ?? true,
      lastLoginAt: map['lastLoginAt']?.toString(),
      avatarPath: map['avatarBase64'] ?? map['avatarPath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'name': name,
      'email': email,
      'role': role,
      'Faculty': faculty,
      'passwordHash': passwordHash,
      'isActive': isActive,
      'lastLoginAt': lastLoginAt,
      'avatarBase64': avatarPath,
    };
  }
}
