import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serbisyo_mobileapp/models/chat_peer_info_model.dart';
import 'package:serbisyo_mobileapp/models/private_chat_message_model.dart';
import 'package:serbisyo_mobileapp/services/chat_service.dart';

class PrivateChatService {
  PrivateChatService({ChatService? chatService, FirebaseFirestore? db})
    : _chat = chatService ?? ChatService(db: db),
      _db = db ?? FirebaseFirestore.instance;

  final ChatService _chat;
  final FirebaseFirestore _db;

  static final Map<String, Future<ChatPeerInfoModel>> _peerInfoCache =
      <String, Future<ChatPeerInfoModel>>{};

  Future<ChatPeerInfoModel> resolvePeerInfo({
    required String peerId,
    required String fallbackName,
  }) {
    final key = peerId.trim();
    if (key.isEmpty) {
      return Future.value(ChatPeerInfoModel(name: fallbackName, photoUrl: ''));
    }

    return _peerInfoCache.putIfAbsent(key, () async {
      Future<ChatPeerInfoModel?> fromCollection(String collection) async {
        final snap = await _db.collection(collection).doc(key).get();
        final data = snap.data();
        if (data == null) return null;

        final first = (data['firstName'] ?? '').toString().trim();
        final last = (data['lastName'] ?? '').toString().trim();
        final full = [first, last].where((s) => s.isNotEmpty).join(' ');
        final photoUrl = (data['photoUrl'] ?? '').toString().trim();

        return ChatPeerInfoModel(
          name: full.isNotEmpty ? full : fallbackName,
          photoUrl: photoUrl,
        );
      }

      try {
        return await fromCollection('users') ??
            await fromCollection('providers') ??
            ChatPeerInfoModel(name: fallbackName, photoUrl: '');
      } catch (_) {
        return ChatPeerInfoModel(name: fallbackName, photoUrl: '');
      }
    });
  }

  Stream<List<PrivateChatMessageModel>> watchMessages({
    required String chatId,
    required String myUserId,
    Duration timeBreakThreshold = const Duration(minutes: 5),
  }) {
    final id = chatId.trim();
    if (id.isEmpty || myUserId.trim().isEmpty) {
      return const Stream<List<PrivateChatMessageModel>>.empty();
    }

    return _chat.messagesQuery(chatId: id).snapshots().map((snapshot) {
      final docs = snapshot.docs;
      final result = <PrivateChatMessageModel>[];

      DateTime? prevDt;
      String? prevSenderId;

      for (final doc in docs) {
        final data = doc.data();

        final rawType = (data['type'] ?? 'text').toString();
        final type = rawType == 'image'
            ? PrivateChatMessageType.image
            : PrivateChatMessageType.text;

        final text = (data['text'] ?? '').toString();
        final imageUrl = (data['imageUrl'] ?? '').toString().trim();
        final senderId = (data['senderId'] ?? '').toString();

        final ts =
            (data['createdAtClient'] as Timestamp?) ??
            (data['createdAt'] as Timestamp?);
        final dt = (ts ?? Timestamp.now()).toDate();

        bool showTime = true;
        if (prevDt != null) {
          final sameSender =
              prevSenderId != null &&
              prevSenderId.isNotEmpty &&
              prevSenderId == senderId;
          final gap = dt.difference(prevDt);
          final hasBigGap = gap.abs() >= timeBreakThreshold;
          showTime = !sameSender || hasBigGap;
        }

        final timeLabel = _formatTime(dt);

        result.add(
          PrivateChatMessageModel(
            type: type,
            text: text,
            imageUrl: imageUrl,
            senderId: senderId,
            isMe: senderId == myUserId,
            createdAt: dt,
            timeLabel: timeLabel,
            showTime: showTime,
          ),
        );

        prevDt = dt;
        prevSenderId = senderId;
      }

      return result;
    });
  }

  static String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
