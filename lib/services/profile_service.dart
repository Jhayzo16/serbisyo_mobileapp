import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serbisyo_mobileapp/models/profile_model.dart';
import 'package:serbisyo_mobileapp/services/storage_service.dart';

class ProfileService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final StorageService _storage;

  ProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
    StorageService? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _db = db ?? FirebaseFirestore.instance,
       _storage = storage ?? StorageService();

  Future<ProfileModel?> loadCurrent({required bool isProvider}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final collection = isProvider ? 'providers' : 'users';
    final snap = await _db.collection(collection).doc(user.uid).get();
    final data = snap.data() ?? <String, dynamic>{};

    return ProfileModel.fromMap(
      uid: user.uid,
      fallbackEmail: user.email ?? '',
      isProvider: isProvider,
      data: data,
    );
  }

  Future<void> save({
    required bool isProvider,
    required ProfileModel profile,
  }) async {
    final collection = isProvider ? 'providers' : 'users';
    await _db.collection(collection).doc(profile.uid).set({
      ...profile.toFirestore(isProvider: isProvider),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<ProfileModel> saveProfilePhoto({
    required bool isProvider,
    required ProfileModel profile,
    required XFile file,
  }) async {
    final roleFolder = isProvider ? 'providers' : 'users';
    final safeName = file.name.isNotEmpty ? file.name : 'photo.jpg';
    final storagePath =
        'profile_photos/$roleFolder/${profile.uid}/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    final url = await _storage.uploadXFile(
      file: file,
      storagePath: storagePath,
    );
    final next = profile.copyWith(photoUrl: url);
    await save(isProvider: isProvider, profile: next);
    return next;
  }
}
