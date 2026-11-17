import 'dart:convert';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/staff_user.dart';
import '../services/profile_service.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final StaffUser user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late StaffUser _user;
  bool _showPassword = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _fetchRealFirebaseProfile();
  }

  Future<void> _fetchRealFirebaseProfile() async {
    try {
      final freshUser = await ProfileService().fetchProfile(_user.staffId);
      if (mounted) {
        setState(() {
          _user = freshUser;
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _openEditProfile() async {
    final updatedUser = await Navigator.push<StaffUser>(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(user: _user)),
    );

    if (updatedUser != null && mounted) {
      setState(() {
        _user = updatedUser;
      });
    }
  }

  void _showPasswordInfo() {
    setState(() {
      _showPassword = !_showPassword;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Passwords are securely stored and cannot be viewed. '
          'Use Edit Profile to change your password.',
        ),
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarData = _user.avatarPath;

    Widget avatarContent = const Icon(
      Icons.person,
      size: 70,
      color: AppColors.primaryBlue,
    );

    if (avatarData != null && avatarData.isNotEmpty) {
      try {
        avatarContent = Image.memory(
          base64Decode(avatarData),
          fit: BoxFit.cover,
          width: 116,
          height: 116,
        );
      } catch (_) {}
    }

    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEFF4FF),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(child: avatarContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, _user),
                          child: const Text(
                            '< Back',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: Color(0xFFD0BCFF),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Exora',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _logout,
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'PROFILE',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_isLoadingProfile) ...[
                          const SizedBox(width: 12),
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          _buildAvatar(),
                          const SizedBox(height: 14),
                          Text(
                            _user.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3185EF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _user.role.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileItem('Full Name', _user.name),
                          _buildProfileItem('Staff ID', _user.staffId),
                          _buildProfileItem('Role', _user.role),
                          _buildProfileItem('Faculty', _user.faculty),
                          _buildProfileItem('Email', _user.email),
                          const Text(
                            'Password:',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  '••••••••••••',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _showPasswordInfo,
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.blueGrey,
                                  size: 21,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _openEditProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F6BEA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'EDIT PROFILE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
