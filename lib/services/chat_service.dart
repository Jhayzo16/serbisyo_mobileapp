import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _db;

  ChatService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  String chatIdForUsers({required String userA, required String userB}) {
    final a = userA.trim();
    final b = userB.trim();
    if (a.isEmpty || b.isEmpty) return '';
    final pair = [a, b]..sort();
    return '${pair[0]}__${pair[1]}';
  }

  Future<void> ensureChat({
    required String chatId,
    required List<String> participantIds,
  }) async {
    final ids = participantIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (chatId.trim().isEmpty || ids.length < 2) return;

    await _db.collection('chats').doc(chatId).set({
      'participants': ids,
      'createdAt': FieldValue.serverTimestamp(),
      'createdAtClient': Timestamp.now(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedAtClient': Timestamp.now(),
      'lastText': '',
    }, SetOptions(merge: true));
  }

  String chatId({required String userId, required String peerKey}) {
    final normalized = peerKey
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_\-]'), '');
    return '${userId}_$normalized';
  }

  Query<Map<String, dynamic>> messagesQuery({required String chatId}) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAtClient', descending: false);
  }

  Future<void> sendText({
    required String chatId,
    required String senderId,
    required String text,
    List<String>? participantIds,
  }) {
    final doc = _db.collection('chats').doc(chatId);

    final batch = _db.batch();

    final messageRef = doc.collection('messages').doc();
    batch.set(messageRef, {
      'text': text,
      'senderId': senderId,
      'createdAt': FieldValue.serverTimestamp(),
      'createdAtClient': Timestamp.now(),
    });

    final ids = (participantIds ?? const <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (ids.length >= 2) {
      batch.set(doc, {'participants': ids}, SetOptions(merge: true));
    }

    batch.set(doc, {
      'lastText': text,
      'lastSenderId': senderId,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedAtClient': Timestamp.now(),
    }, SetOptions(merge: true));

    // In-app notifications for recipients
    if (ids.isNotEmpty) {
      for (final recipientId in ids) {
        if (recipientId == senderId) continue;
        final notifRef = _db.collection('notifications').doc();
        batch.set(notifRef, {
          'recipientId': recipientId,
          'senderId': senderId,
          'type': 'message',
          'title': 'Message',
          'body': 'Someone sent you a message',
          'chatId': chatId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
          'createdAtClient': Timestamp.now(),
        });
      }
    }

    return batch.commit();
  }

  Future<void> sendImage({
    required String chatId,
    required String senderId,
    required String imageUrl,
    List<String>? participantIds,
  }) {
    final url = imageUrl.trim();
    if (url.isEmpty) return Future.value();

    final doc = _db.collection('chats').doc(chatId);
    final batch = _db.batch();

    final messageRef = doc.collection('messages').doc();
    batch.set(messageRef, {
      'type': 'image',
      'imageUrl': url,
      'senderId': senderId,
      'createdAt': FieldValue.serverTimestamp(),
      'createdAtClient': Timestamp.now(),
    });

    final ids = (participantIds ?? const <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (ids.length >= 2) {
      batch.set(doc, {'participants': ids}, SetOptions(merge: true));
    }

    batch.set(doc, {
      'lastText': 'Photo',
      'lastSenderId': senderId,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedAtClient': Timestamp.now(),
    }, SetOptions(merge: true));

    // In-app notifications for recipients
    if (ids.isNotEmpty) {
      for (final recipientId in ids) {
        if (recipientId == senderId) continue;
        final notifRef = _db.collection('notifications').doc();
        batch.set(notifRef, {
          'recipientId': recipientId,
          'senderId': senderId,
          'type': 'message',
          'title': 'Photo',
          'body': 'Someone sent you a photo',
          'chatId': chatId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
          'createdAtClient': Timestamp.now(),
        });
      }
    }

    return batch.commit();
  }
}
