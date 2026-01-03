import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/message_thread_model.dart';

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

  final List<_ChatMessage> _messages = [
    const _ChatMessage(text: 'Ako nay bahala sa snack nimo', isMe: true),
    const _ChatMessage(text: 'Sige sigee salamatt', isMe: false),
    const _ChatMessage(text: 'Asa naka?', isMe: true),
    const _ChatMessage(text: 'Otw nako sir', isMe: false),
    const _ChatMessage(text: 'Hulata rako sa gawas sirr', isMe: false),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isMe: true));
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _bubble(BuildContext context, _ChatMessage message) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;
    final isMe = message.isMe;

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
            message.text,
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _bubble(context, _messages[index]),
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
