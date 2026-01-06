import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serbisyo_mobileapp/pages/login_user_page.dart';
import 'package:serbisyo_mobileapp/services/auth_service.dart';
import 'package:serbisyo_mobileapp/services/storage_service.dart';

class SignupProviderWidget extends StatefulWidget {
  const SignupProviderWidget({super.key});

  @override
  State<SignupProviderWidget> createState() => _SignupProviderWidgetState();
}

class _SignupProviderWidgetState extends State<SignupProviderWidget> {
  static const _brandColor = Color(0xFF2D6B7A);
  static const _fieldFill = Color(0xFFF3F4F6);

  final _authService = AuthService();
  final _storageService = StorageService();
  final _db = FirebaseFirestore.instance;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _picker = ImagePicker();
  XFile? _photo;
  Uint8List? _photoBytes;

  bool _isPickingPhoto = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _jobTitleController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto) return;
    setState(() => _isPickingPhoto = true);
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photo = file;
        _photoBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick photo')));
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      border: InputBorder.none,
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: _fieldFill,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword,
            decoration: _decoration(''),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final cred = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      final uid = cred.user?.uid;
      if (uid == null) {
        throw StateError('Failed to create account');
      }

      String? photoUrl;
      final picked = _photo;
      if (picked != null) {
        final safeName = picked.name.replaceAll(
          RegExp(r'[^a-zA-Z0-9._-]'),
          '_',
        );
        final storagePath = 'providers/$uid/profile_$safeName';
        photoUrl = await _storageService.uploadXFile(
          file: picked,
          storagePath: storagePath,
        );
      }

      await _db.collection('providers').doc(uid).set({
        'uid': uid,
        'role': 'provider',
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'jobTitle': _jobTitleController.text.trim(),
        'location': _locationController.text.trim(),
        'email': email,
        'phone': _phoneController.text.trim(),
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      await _authService.signOut();
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginUserPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = switch (e) {
        FirebaseAuthException _ => authErrorMessage(e),
        FirebaseException _ => e.message ?? 'Signup failed.',
        StateError _ => e.message,
        _ => 'Signup failed.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final colGap = width >= 360 ? 18.0 : 12.0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sign up as Provider',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Photo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 74,
              height: 74,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE5E7EB),
                    ),
                    child: _photoBytes == null
                        ? const SizedBox.shrink()
                        : ClipOval(
                            child: Image.memory(
                              _photoBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  if (_isPickingPhoto)
                    const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 30,
              child: OutlinedButton.icon(
                onPressed: _isPickingPhoto ? null : _pickPhoto,
                icon: const Icon(Icons.upload_file_outlined, size: 16),
                label: const Text(
                  'Upload Photo',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    label: 'First Name',
                    controller: _firstNameController,
                  ),
                ),
                SizedBox(width: colGap),
                Expanded(
                  child: _field(
                    label: 'Choose a Password',
                    controller: _passwordController,
                    isPassword: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    label: 'Last Name',
                    controller: _lastNameController,
                  ),
                ),
                SizedBox(width: colGap),
                Expanded(
                  child: _field(
                    label: 'Job Title',
                    controller: _jobTitleController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    label: 'Location',
                    controller: _locationController,
                  ),
                ),
                SizedBox(width: colGap),
                Expanded(
                  child: _field(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                SizedBox(width: colGap),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: 180,
              height: 44,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isSubmitting ? 'PLEASE WAIT' : 'SIGNUP',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            if (_photo != null) ...[
              const SizedBox(height: 10),
              Text(
                _photo!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
