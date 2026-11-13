/// Data model representing a staff member in Exora.
class StaffUser {
  final String staffId;
  final String name;
  final String role;
  final String passwordHash;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  StaffUser({
    required this.staffId,
    required this.name,
    required this.role,
    required this.passwordHash,
    this.isActive = true,
    this.createdAt,
    this.lastLoginAt,
  });

  factory StaffUser.fromMap(Map<String, dynamic> map, String docId) {
    return StaffUser(
      staffId: map['staffId'] as String? ?? docId,
      name: map['name'] as String? ?? 'Staff Member',
      role: map['role'] as String? ?? 'Staff',
      passwordHash: map['passwordHash'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.tryParse(map['lastLoginAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'name': name,
      'role': role,
      'passwordHash': passwordHash,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}
