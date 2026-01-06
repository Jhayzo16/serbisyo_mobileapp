import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/notification_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serbisyo_mobileapp/models/profile_model.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/home_page.dart';
import 'package:serbisyo_mobileapp/pages/jobs_page.dart';
import 'package:serbisyo_mobileapp/pages/login_user_page.dart';
import 'package:serbisyo_mobileapp/pages/provider_homepage.dart';
import 'package:serbisyo_mobileapp/pages/your_request_page.dart';
import 'package:serbisyo_mobileapp/services/auth_service.dart';
import 'package:serbisyo_mobileapp/services/profile_service.dart';
import 'package:serbisyo_mobileapp/widgets/profile_page_widget/profile_info_row.dart';
import 'package:serbisyo_mobileapp/widgets/profile_page_widget/profile_section_title.dart';
import 'package:serbisyo_mobileapp/widgets/profile_page_widget/profile_text_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.isProvider = false});

  final bool isProvider;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _primaryColor = Color(0xff254356);
  static const _selectedColor = Color(0xff356785);
  static const _unselectedColor = Color(0xffBFBFBF);
  static const _fieldFill = Color(0xFFF3F4F6);
  static const _muted = Color(0xff7C7979);

  final _auth = AuthService();
  final _profileService = ProfileService();
  final _picker = ImagePicker();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _jobTitle = TextEditingController();
  final _location = TextEditingController();

  bool _isEditing = false;
  bool _loading = true;
  bool _uploadingPhoto = false;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _jobTitle.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await _profileService.loadCurrent(
        isProvider: widget.isProvider,
      );
      _profile = profile;
      _firstName.text = profile?.firstName ?? '';
      _lastName.text = profile?.lastName ?? '';
      _phone.text = profile?.phone ?? '';
      _jobTitle.text = profile?.jobTitle ?? '';
      _location.text = profile?.location ?? '';
    } catch (_) {
      // keep defaults
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final first = _firstName.text.trim();
    final last = _lastName.text.trim();
    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name and last name are required')),
      );
      return;
    }

    try {
      final current = _profile;
      final next =
          (current ??
                  ProfileModel(
                    uid: user.uid,
                    role: widget.isProvider ? 'provider' : 'user',
                    email: user.email ?? '',
                    firstName: '',
                    lastName: '',
                    phone: '',
                  ))
              .copyWith(
                firstName: first,
                lastName: last,
                phone: _phone.text.trim(),
                jobTitle: _jobTitle.text.trim(),
                location: _location.text.trim(),
              );

      await _profileService.save(isProvider: widget.isProvider, profile: next);
      _profile = next;

      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
    } finally {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginUserPage()),
        (route) => false,
      );
    }
  }

  Future<void> _pickAndSavePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 900,
      );
      if (picked == null) return;

      final current =
          _profile ??
          ProfileModel(
            uid: user.uid,
            role: widget.isProvider ? 'provider' : 'user',
            email: user.email ?? '',
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            phone: _phone.text.trim(),
            jobTitle: _jobTitle.text.trim(),
            location: _location.text.trim(),
          );

      setState(() => _uploadingPhoto = true);
      final next = await _profileService.saveProfilePhoto(
        isProvider: widget.isProvider,
        profile: current,
        file: picked,
      );

      _profile = next;
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile photo: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Widget _profilePhoto(ProfileModel? profile) {
    final url = profile?.photoUrl.trim() ?? '';
    final hasUrl = url.isNotEmpty;

    return GestureDetector(
      onTap: _uploadingPhoto ? null : _pickAndSavePhoto,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: _fieldFill,
            backgroundImage: hasUrl ? NetworkImage(url) : null,
            child: hasUrl
                ? null
                : const Icon(Icons.person, size: 44, color: _muted),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _uploadingPhoto
                  ? const Padding(
                      padding: EdgeInsets.all(6),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return ProfileSectionTitle(title: title);
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return ProfileTextField(
      label: label,
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
    );
  }

  Widget _infoRow(String label, String value) {
    return ProfileInfoRow(label: label, value: value);
  }

  Container _navToolbar(BuildContext context) {
    if (widget.isProvider) {
      return Container(
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ProviderHomepage()),
                );
              },
              child: ImageIcon(
                const AssetImage('assets/icons/provider_home_icon.png'),
                color: _unselectedColor,
                size: 26,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const JobsPage()),
                );
              },
              child: ImageIcon(
                const AssetImage('assets/icons/your_jobs_icon.png'),
                color: _unselectedColor,
                size: 26,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const ChatPage(isProvider: true),
                  ),
                );
              },
              child: ImageIcon(
                const AssetImage('assets/icons/message_icon.png'),
                color: _unselectedColor,
                size: 26,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
              ),
              child: ImageIcon(
                const AssetImage('assets/icons/profile_icon.png'),
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            child: ImageIcon(
              const AssetImage('assets/icons/home_icon.png'),
              color: _unselectedColor,
              size: 26,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const YourRequestPage()),
              );
            },
            child: ImageIcon(
              const AssetImage('assets/icons/request_icon.png'),
              color: _unselectedColor,
              size: 26,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChatPage()),
              );
            },
            child: ImageIcon(
              const AssetImage('assets/icons/message_icon.png'),
              color: _unselectedColor,
              size: 26,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: _selectedColor,
              shape: BoxShape.circle,
            ),
            child: ImageIcon(
              const AssetImage('assets/icons/profile_icon.png'),
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 100,
      title: Container(
        margin: const EdgeInsets.only(top: 50, left: 20),
        child: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: _primaryColor,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(top: 50, right: 20),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      NotificationPage(isProvider: widget.isProvider),
                ),
              );
            },
            icon: const Icon(
              size: 40,
              color: Colors.black,
              Icons.notifications,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = FirebaseAuth.instance.currentUser;
    final profile = _profile;

    return Scaffold(
      appBar: _appBar(context),
      bottomNavigationBar: _navToolbar(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : current == null
          ? const Center(
              child: Text(
                'Please log in.',
                style: TextStyle(color: Colors.black45),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _profilePhoto(profile)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle('Profile Details'),
                        TextButton(
                          onPressed: () {
                            if (_isEditing) {
                              _save();
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                          child: Text(
                            _isEditing ? 'Save' : 'Edit',
                            style: const TextStyle(
                              color: _primaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _field(label: 'First Name', controller: _firstName),
                    const SizedBox(height: 12),
                    _field(label: 'Last Name', controller: _lastName),
                    const SizedBox(height: 12),
                    _field(
                      label: 'Phone',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                    ),
                    if (widget.isProvider) ...[
                      const SizedBox(height: 12),
                      _field(label: 'Job Title', controller: _jobTitle),
                      const SizedBox(height: 12),
                      _field(label: 'Location', controller: _location),
                    ],
                    const SizedBox(height: 18),
                    _sectionTitle('Account Details'),
                    const SizedBox(height: 10),
                    _infoRow('Email', profile?.email ?? ''),
                    const SizedBox(height: 10),
                    _infoRow('Role', profile?.role ?? ''),
                    const SizedBox(height: 22),
                    _sectionTitle('Actions'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
