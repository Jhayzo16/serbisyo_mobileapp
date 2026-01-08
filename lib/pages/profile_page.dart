import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/notification_page.dart';
import 'package:serbisyo_mobileapp/models/profile_model.dart';
import 'package:serbisyo_mobileapp/pages/login_user_page.dart';
import 'package:serbisyo_mobileapp/pages/provider_job_profile_page.dart';
import 'package:serbisyo_mobileapp/services/auth_service.dart';
import 'package:serbisyo_mobileapp/pages/profile_actions.dart';
import 'package:serbisyo_mobileapp/services/profile_service.dart';
import 'package:serbisyo_mobileapp/widgets/notification_bell_badge.dart';
import 'package:serbisyo_mobileapp/widgets/profile_page_widget/profile_bottom_nav_bar.dart';
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
  static const _fieldFill = Color(0xFFF3F4F6);
  static const _muted = Color(0xff7C7979);

  final _auth = AuthService();
  final _profileService = ProfileService();
  late final _actions = ProfileActions(
    auth: _auth,
    profileService: _profileService,
  );

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
      final profile = await _actions.loadCurrent(isProvider: widget.isProvider);
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
    final user = _auth.currentUser;
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
      final next = await _actions.saveProfile(
        isProvider: widget.isProvider,
        currentProfile: _profile,
        firstName: first,
        lastName: last,
        phone: _phone.text.trim(),
        jobTitle: _jobTitle.text.trim(),
        location: _location.text.trim(),
      );
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
      await _actions.logout();
    } finally {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginUserPage()),
        (route) => false,
      );
    }
  }

  Future<void> _pickAndSavePhoto() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
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
      final next = await _actions.pickAndSavePhoto(
        isProvider: widget.isProvider,
        currentDraft: current,
      );
      if (next != null) {
        _profile = next;
      } else {
        return;
      }
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
          child: NotificationBellBadge(
            iconSize: 40,
            iconColor: Colors.black,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      NotificationPage(isProvider: widget.isProvider),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _auth.currentUser;
    final profile = _profile;

    return Scaffold(
      appBar: _appBar(context),
      bottomNavigationBar: ProfileBottomNavBar(isProvider: widget.isProvider),
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
                        const ProfileSectionTitle(title: 'Profile Details'),
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
                    ProfileTextField(
                      label: 'First Name',
                      controller: _firstName,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 12),
                    ProfileTextField(
                      label: 'Last Name',
                      controller: _lastName,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 12),
                    ProfileTextField(
                      label: 'Phone',
                      controller: _phone,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    if (widget.isProvider) ...[
                      const SizedBox(height: 12),
                      ProfileTextField(
                        label: 'Job Title',
                        controller: _jobTitle,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 12),
                      ProfileTextField(
                        label: 'Location',
                        controller: _location,
                        enabled: _isEditing,
                      ),
                    ],
                    const SizedBox(height: 18),
                    const ProfileSectionTitle(title: 'Account Details'),
                    const SizedBox(height: 10),
                    ProfileInfoRow(label: 'Email', value: profile?.email ?? ''),
                    const SizedBox(height: 10),
                    ProfileInfoRow(label: 'Role', value: profile?.role ?? ''),
                    const SizedBox(height: 22),
                    const ProfileSectionTitle(title: 'Actions'),
                    const SizedBox(height: 12),
                    if (widget.isProvider) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProviderJobProfilePage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Job Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
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
