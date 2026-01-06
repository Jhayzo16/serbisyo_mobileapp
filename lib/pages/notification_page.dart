import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/your_request_page.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key, this.isProvider = false});

  final bool isProvider;

  static const _titleColor = Color(0xff254356);

  String _formatTime(Timestamp? ts) {
    final dt = (ts ?? Timestamp.now()).toDate();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _titleColor,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Please log in to see notifications.',
            style: TextStyle(color: Colors.black45),
          ),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: me)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _titleColor,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load notifications',
                style: TextStyle(color: Colors.black45),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final aTs =
                  (a.data()['createdAtClient'] as Timestamp?) ??
                  (a.data()['createdAt'] as Timestamp?) ??
                  Timestamp(0, 0);
              final bTs =
                  (b.data()['createdAtClient'] as Timestamp?) ??
                  (b.data()['createdAt'] as Timestamp?) ??
                  Timestamp(0, 0);
              return bTs.compareTo(aTs);
            });

          final supportedDocs = docs.where((d) {
            final type = (d.data()['type'] ?? '').toString();
            return type == 'message' || type == 'requestAccepted';
          }).toList();

          if (supportedDocs.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: Colors.black45),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            itemCount: supportedDocs.length,
            separatorBuilder: (_, __) =>
                Divider(height: 18, thickness: 1, color: Colors.grey.shade300),
            itemBuilder: (context, index) {
              final doc = supportedDocs[index];
              final data = doc.data();
              final type = (data['type'] ?? '').toString();

              final title = type == 'message'
                  ? 'Message'
                  : type == 'requestAccepted'
                  ? 'Request accepted'
                  : (data['title'] ?? 'Serbisyo').toString();
              final body = type == 'message'
                  ? 'Someone sent you a message'
                  : type == 'requestAccepted'
                  ? (data['body'] ?? 'Your request has been accepted!')
                        .toString()
                  : (data['body'] ?? '').toString();
              final read = (data['read'] ?? false) == true;
              final time = _formatTime(
                (data['createdAtClient'] as Timestamp?) ??
                    (data['createdAt'] as Timestamp?),
              );

              return InkWell(
                onTap: () async {
                  try {
                    await doc.reference.set({
                      'read': true,
                      'readAt': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));
                  } catch (_) {
                    // ignore
                  }

                  if (!context.mounted) return;

                  if (type == 'message') {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => ChatPage(isProvider: isProvider),
                      ),
                    );
                  } else if (type == 'requestAccepted') {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const YourRequestPage(),
                      ),
                    );
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icons/Pelican.png',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff7C7979),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xff7C7979),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (!read)
                          Container(
                            width: 18,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
