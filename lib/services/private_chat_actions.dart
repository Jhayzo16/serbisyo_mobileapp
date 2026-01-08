import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serbisyo_mobileapp/services/chat_service.dart';
import 'package:serbisyo_mobileapp/services/storage_service.dart';

class PrivateChatActions {
  PrivateChatActions({
    FirebaseAuth? auth,
    ChatService? chatService,
    StorageService? storageService,
    ImagePicker? picker,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _chat = chatService ?? ChatService(),
       _storage = storageService ?? StorageService(),
       _picker = picker ?? ImagePicker();

  final FirebaseAuth _auth;
  final ChatService _chat;
  final StorageService _storage;
  final ImagePicker _picker;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> sendText({
    required String chatId,
    required String peerId,
    required String text,
  }) async {
    final senderId = currentUserId;
    final id = chatId.trim();
    final peer = peerId.trim();
    final message = text.trim();

    if (senderId == null || id.isEmpty || peer.isEmpty || message.isEmpty) {
      return;
    }

    await _chat.sendText(
      chatId: id,
      senderId: senderId,
      text: message,
      participantIds: [senderId, peer],
    );
  }

  Future<void> pickAndSendImage({
    required String chatId,
    required String peerId,
  }) async {
    final senderId = currentUserId;
    final id = chatId.trim();
    final peer = peerId.trim();

    if (senderId == null || id.isEmpty || peer.isEmpty) return;

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final safeName = file.name.trim().isNotEmpty
        ? file.name.trim()
        : 'image_$now.jpg';
    final storagePath = 'chats/$id/$now-$safeName';

    final imageUrl = await _storage.uploadXFile(
      file: file,
      storagePath: storagePath,
    );

    await _chat.sendImage(
      chatId: id,
      senderId: senderId,
      imageUrl: imageUrl,
      participantIds: [senderId, peer],
    );
  }
}
