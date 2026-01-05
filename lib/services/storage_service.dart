import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadXFile({
    required XFile file,
    required String storagePath,
  }) async {
    final bytes = await file.readAsBytes();
    final contentType = lookupMimeType(file.name) ?? 'application/octet-stream';

    final ref = _storage.ref(storagePath);
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }
}
