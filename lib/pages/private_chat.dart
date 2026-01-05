import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serbisyo_mobileapp/models/message_thread_model.dart';
import 'package:serbisyo_mobileapp/services/chat_service.dart';

class PrivateChat extends StatefulWidget {
  const PrivateChat({super.key, required this.thread});

  final MessageThreadModel thread;

  @override
  State<PrivateChat> createState() => _PrivateChatState();
}

class _PrivateChatState extends State<PrivateChat> {
  static const _titleColor = Color(0xff254356);
  static const _myBubbleColor = Color(0xff356785);
  static const _theirBubbleColor = Color(0xffE9E9E9);
  static const _inputFill = Color(0xffE9E9E9);

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _chat = ChatService();

  Future<String> _resolvePeerName({required String peerId}) async {
    final current = widget.thread.name.trim();
    if (current.isNotEmpty && current.toLowerCase() != 'customer')
      return current;

    try {
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

      final resolved =
          await fromCollection('users') ?? await fromCollection('providers');
      if (resolved != null) return resolved;
    } catch (_) {
      // ignore
    }
    return current.isNotEmpty ? current : 'Chat';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final senderId = FirebaseAuth.instance.currentUser?.uid;
    final chatId = widget.thread.chatId;
    final peerId = widget.thread.peerId.trim();
    if (senderId == null || chatId.trim().isEmpty || peerId.isEmpty) return;

    _controller.clear();
    _chat.sendText(
      chatId: chatId,
      senderId: senderId,
      text: text,
      participantIds: [senderId, peerId],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _bubble(
    BuildContext context, {
    required String text,
    required bool isMe,
  }) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isMe ? _theirBubbleColor : _myBubbleColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isMe ? _titleColor : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser?.uid;
    final chatId = widget.thread.chatId;
    final peerId = widget.thread.peerId.trim();

    if (me == null || chatId.trim().isEmpty || peerId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.thread.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _titleColor,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Chat is not available.',
            style: TextStyle(color: Colors.black45),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: FutureBuilder<String>(
          future: _resolvePeerName(peerId: peerId),
          builder: (context, snap) {
            final name = (snap.data ?? widget.thread.name).trim();
            return Text(
              name.isNotEmpty ? name : 'Chat',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _titleColor,
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _chat.messagesQuery(chatId: chatId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Failed to load messages',
                        style: TextStyle(color: Colors.black45),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? const [];

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_scrollController.hasClients) return;
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final text = (data['text'] ?? '').toString();
                      final senderId = (data['senderId'] ?? '').toString();
                      final isMe = senderId == me;
                      return _bubble(context, text: text, isMe: isMe);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _inputFill,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.attach_file, color: _titleColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(),
                              decoration: const InputDecoration(
                                hintText: 'Type a message',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _send,
                    borderRadius: BorderRadius.circular(28),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.send, size: 28, color: _myBubbleColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;

  const _ChatMessage({required this.text, required this.isMe});
}
