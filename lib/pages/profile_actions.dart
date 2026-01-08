import 'package:image_picker/image_picker.dart';
import 'package:serbisyo_mobileapp/models/profile_model.dart';
import 'package:serbisyo_mobileapp/services/auth_service.dart';
import 'package:serbisyo_mobileapp/services/profile_service.dart';

class ProfileActions {
  ProfileActions({
    AuthService? auth,
    ProfileService? profileService,
    ImagePicker? picker,
  }) : _auth = auth ?? AuthService(),
       _profileService = profileService ?? ProfileService(),
       _picker = picker ?? ImagePicker();

  final AuthService _auth;
  final ProfileService _profileService;
  final ImagePicker _picker;

  Object? get currentUser => _auth.currentUser;

  Future<ProfileModel?> loadCurrent({required bool isProvider}) {
    return _profileService.loadCurrent(isProvider: isProvider);
  }

  Future<ProfileModel> saveProfile({
    required bool isProvider,
    required ProfileModel? currentProfile,
    required String firstName,
    required String lastName,
    required String phone,
    required String jobTitle,
    required String location,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not authenticated');

    final base =
        currentProfile ??
        ProfileModel(
          uid: user.uid,
          role: isProvider ? 'provider' : 'user',
          email: user.email ?? '',
          firstName: '',
          lastName: '',
          phone: '',
        );

    final next = base.copyWith(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      jobTitle: jobTitle,
      location: location,
    );

    await _profileService.save(isProvider: isProvider, profile: next);
    return next;
  }

  Future<ProfileModel?> pickAndSavePhoto({
    required bool isProvider,
    required ProfileModel currentDraft,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not authenticated');

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 900,
    );
    if (picked == null) return null;

    return _profileService.saveProfilePhoto(
      isProvider: isProvider,
      profile: currentDraft,
      file: picked,
    );
  }

  Future<void> logout() => _auth.signOut();
}
