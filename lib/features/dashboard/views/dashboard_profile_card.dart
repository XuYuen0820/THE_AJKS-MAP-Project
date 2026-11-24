import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/models/staff_user.dart';
import '../../../../core/utils/app_colors.dart';

class DashboardProfileCard extends StatelessWidget {
  final StaffUser user;
  final Key? cardKey;
  final VoidCallback onTap;

  const DashboardProfileCard({
    super.key,
    required this.user,
    this.cardKey,
    required this.onTap,
  });

  Widget _buildAvatar() {
    final avatarData = user.avatarPath;
    Widget child = const Icon(
      Icons.person_rounded,
      size: 36,
      color: AppColors.primaryBlue,
    );

    if (avatarData != null && avatarData.isNotEmpty) {
      try {
        child = Image.memory(
          base64Decode(avatarData),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        );
      } catch (_) {}
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEFF4FF),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: ClipOval(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        key: cardKey,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00007A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.more_vert, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
