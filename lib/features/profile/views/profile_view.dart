import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/models/staff_user.dart';
import '../../../core/utils/app_colors.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileView extends StatefulWidget {
  final StaffUser user;
  final ProfileViewModel viewModel;

  const ProfileView({super.key, required this.user, required this.viewModel});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initUser(widget.user);
    widget.viewModel.loadLatestProfile();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _openEditProfile() async {
    final updatedUser = await Navigator.pushNamed(
      context,
      AppRouter.editProfile,
      arguments: widget.viewModel.user,
    ) as StaffUser?;

    if (updatedUser != null && mounted) {
      widget.viewModel.setUser(updatedUser);
    }
  }

  void _showPasswordInfo() {
    widget.viewModel.togglePasswordHint();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Passwords are securely stored and cannot be viewed. '
          'Use Edit Profile to change your password.',
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final success = await widget.viewModel.signOut();
    if (!mounted) return;

    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (widget.viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to log out: ${widget.viewModel.errorMessage}'),
        ),
      );
    }
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

  Widget _buildAvatar(StaffUser user) {
    final avatarData = user.avatarPath;
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
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final user = widget.viewModel.user;
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
                              onPressed: () => Navigator.pop(context, user),
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
                            if (widget.viewModel.isLoading) ...[
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
                              _buildAvatar(user),
                              const SizedBox(height: 14),
                              Text(
                                user.name.toUpperCase(),
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
                                  user.role.toUpperCase(),
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
                              _buildProfileItem('Full Name', user.name),
                              _buildProfileItem('Staff ID', user.staffId),
                              _buildProfileItem('Role', user.role),
                              _buildProfileItem('Faculty', user.faculty),
                              _buildProfileItem('Email', user.email),
                              const Text(
                                'Password:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
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
                                      widget.viewModel.showPasswordHint
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
      },
    );
  }
}
