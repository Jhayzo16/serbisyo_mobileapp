import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serbisyo_mobileapp/pages/login_user_page.dart';
import 'package:serbisyo_mobileapp/services/auth_service.dart';
import 'package:serbisyo_mobileapp/services/storage_service.dart';
import 'dart:typed_data';

class SignupUserWidget extends StatefulWidget {
  const SignupUserWidget({super.key});

  @override
  State<SignupUserWidget> createState() => _SignupUserWidgetState();
}

class _SignupUserWidgetState extends State<SignupUserWidget> {
  static const _brandColor = Color(0xFF2D6B7A);

  final _authService = AuthService();
  final _storageService = StorageService();
  final _db = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  XFile? _photo;
  Uint8List? _photoBytes;
  bool _isPickingPhoto = false;

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick photo')));
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _contactNumberController.text.trim();
    final password = _passwordController.text;

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name and last name are required')),
      );
      return;
    }
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
        final storagePath = 'users/$uid/profile_$safeName';
        photoUrl = await _storageService.uploadXFile(
          file: picked,
          storagePath: storagePath,
        );
      }

      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'role': 'user',
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
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
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              Text(
                'Hello User!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create Your Account For\nBetter Experience',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Photo (optional)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
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
                        color: Color(0xFFF3F4F6),
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
              if (_photo != null) ...[
                const SizedBox(height: 8),
                Text(
                  _photo!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              _SignupField(
                hintText: 'First Name',
                controller: _firstNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                trailing: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 14),
              _SignupField(
                hintText: 'Last Name',
                controller: _lastNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                trailing: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 14),
              _SignupField(
                hintText: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                trailing: const Icon(
                  Icons.mail_outline,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 14),
              _SignupField(
                hintText: 'Contact Number',
                controller: _contactNumberController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                trailing: const Icon(
                  Icons.phone_outlined,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 14),
              _SignupField(
                hintText: 'Password',
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                obscureText: _obscurePassword,
                trailing: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF9CA3AF),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'SIGNUP',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xFF25607A),
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignupField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget trailing;

  const _SignupField({
    required this.hintText,
    required this.controller,
    required this.trailing,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
