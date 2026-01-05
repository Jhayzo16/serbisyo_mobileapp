import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serbisyo_mobileapp/models/message_thread_model.dart';
import 'package:serbisyo_mobileapp/pages/private_chat.dart';
import 'package:serbisyo_mobileapp/widgets/chat_page_widget/message_card.dart';

class MessagesPanel extends StatelessWidget {
  const MessagesPanel({super.key});

  static const _muted = Color(0xff9B9B9B);

  Future<String> _peerName(String peerId) async {
    Future<String?> fromCollection(String collection) async {
      final snap = await FirebaseFirestore.instance
          .collection(collection)
          .doc(peerId)
          .get();
      final data = snap.data();
      if (data == null) return null;

      final first = (data['firstName'] ?? '').toString().trim();
      final last = (data['lastName'] ?? '').toString().trim();
      final full = [first, last].where((s) => s.isNotEmpty).join(' ');
      return full.isNotEmpty ? full : null;
    }

    try {
      return await fromCollection('users') ??
          await fromCollection('providers') ??
          'Chat';
    } catch (_) {
      return 'Chat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null) {
      return const Center(
        child: Text(
          'Please log in to see chats.',
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: me)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Failed to load chats',
              style: TextStyle(color: Colors.black45),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No chats yet',
              style: TextStyle(color: Colors.black45),
            ),
          );
        }

        final items = docs.toList()
          ..sort((a, b) {
            final aTs =
                (a.data()['updatedAtClient'] as Timestamp?) ??
                (a.data()['createdAtClient'] as Timestamp?) ??
                Timestamp(0, 0);
            final bTs =
                (b.data()['updatedAtClient'] as Timestamp?) ??
                (b.data()['createdAtClient'] as Timestamp?) ??
                Timestamp(0, 0);
            return bTs.compareTo(aTs);
          });

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
            itemBuilder: (context, index) {
              final doc = items[index];
              final data = doc.data();
              final participantsRaw = data['participants'];
              final participants = (participantsRaw is List)
                  ? participantsRaw.map((e) => e.toString()).toList()
                  : <String>[];
              final peerId = participants.firstWhere(
                (id) => id != me,
                orElse: () => '',
              );

              final lastText = (data['lastText'] ?? '').toString();
              final updatedAtClient =
                  (data['updatedAtClient'] as Timestamp?) ??
                  (data['createdAtClient'] as Timestamp?) ??
                  Timestamp.now();
              final dt = updatedAtClient.toDate();
              final timeLabel =
                  '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

              return FutureBuilder<String>(
                future: peerId.isEmpty
                    ? Future.value('Chat')
                    : _peerName(peerId),
                builder: (context, nameSnap) {
                  final name = nameSnap.data ?? 'Chat';
                  final thread = MessageThreadModel(
                    name: name,
                    messagePreview: lastText.isNotEmpty
                        ? lastText
                        : 'Say hi 👋',
                    timeLabel: timeLabel,
                    unreadCount: 0,
                    avatarAssetPath: 'assets/icons/profile_icon.png',
                    chatId: doc.id,
                    peerId: peerId,
                  );

                  return MessageCard(
                    thread: thread,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PrivateChat(thread: thread),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
