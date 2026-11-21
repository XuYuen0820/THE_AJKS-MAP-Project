import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_colors.dart';
import '../../models/staff_user.dart';
import 'profile_viewmodel.dart';

class EditProfileView extends StatefulWidget {
  final StaffUser user;
  const EditProfileView({super.key, required this.user});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _imagePicker = ImagePicker();
  late final ProfileViewModel _viewModel;

  late TextEditingController _nameController;
  late TextEditingController _staffIdController;
  late TextEditingController _roleController;
  late TextEditingController _facultyController;
  late TextEditingController _emailController;

  Uint8List? _pickedAvatarBytes;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(initialUser: widget.user);
    _nameController = TextEditingController(text: widget.user.name);
    _staffIdController = TextEditingController(text: widget.user.staffId);
    _roleController = TextEditingController(text: widget.user.role);
    _facultyController = TextEditingController(text: widget.user.faculty);
    _emailController = TextEditingController(text: widget.user.email);

    final existingAvatar = widget.user.avatarPath;
    if (existingAvatar != null && existingAvatar.isNotEmpty) {
      try {
        _pickedAvatarBytes = base64Decode(existingAvatar);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _staffIdController.dispose();
    _roleController.dispose();
    _facultyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      imageQuality: 75,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      if (mounted) {
        setState(() => _pickedAvatarBytes = bytes);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      final updatedUser = await _viewModel.saveProfileChanges(
        newPassword: _passwordController.text,
        avatarBytes: _pickedAvatarBytes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated in Firebase!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, updatedUser);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF2F3F7),
          suffixIcon: const Icon(
            Icons.lock_outline,
            color: Colors.grey,
            size: 19,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onVisibilityPressed,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter new password',
          suffixIcon: IconButton(
            onPressed: onVisibilityPressed,
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.blueGrey,
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEFF4FF),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipOval(
            child: _pickedAvatarBytes != null
                ? Image.memory(
                    _pickedAvatarBytes!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.person,
                    size: 72,
                    color: AppColors.primaryBlue,
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF41447D),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
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
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  '< Back',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                'EXORA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(width: 55),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'EDIT PROFILE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Center(child: _buildAvatar()),
                          const SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildReadOnlyField(
                                  'Full Name',
                                  _nameController,
                                ),
                                _buildReadOnlyField(
                                  'Staff ID',
                                  _staffIdController,
                                ),
                                _buildReadOnlyField('Role', _roleController),
                                _buildReadOnlyField(
                                  'Faculty',
                                  _facultyController,
                                ),
                                _buildReadOnlyField('Email', _emailController),
                                const SizedBox(height: 4),
                                const Text(
                                  'Change Password',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _buildPasswordField(
                                  label: 'New Password',
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  onVisibilityPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  validator: (value) {
                                    if (value != null &&
                                        value.isNotEmpty &&
                                        value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                _buildPasswordField(
                                  label: 'Confirm New Password',
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  onVisibilityPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                  validator: (value) {
                                    if (_passwordController.text.isNotEmpty &&
                                        value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: _viewModel.isLoading
                                  ? null
                                  : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F6BEA),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _viewModel.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'UPDATE PROFILE',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
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
