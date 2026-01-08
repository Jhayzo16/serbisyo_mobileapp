import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/message_thread_model.dart';
import 'package:serbisyo_mobileapp/models/private_chat_message_model.dart';
import 'package:serbisyo_mobileapp/services/private_chat_service.dart';
import 'package:serbisyo_mobileapp/services/private_chat_page_actions.dart';
import 'package:serbisyo_mobileapp/widgets/private_chat_page_widget/private_chat_app_bar_title.dart';
import 'package:serbisyo_mobileapp/widgets/private_chat_page_widget/private_chat_composer.dart';
import 'package:serbisyo_mobileapp/widgets/private_chat_page_widget/private_chat_messages_list.dart';

class PrivateChat extends StatefulWidget {
  const PrivateChat({super.key, required this.thread});

  final MessageThreadModel thread;

  @override
  State<PrivateChat> createState() => _PrivateChatState();
}

class _PrivateChatState extends State<PrivateChat> {
  static const _titleColor = Color(0xff254356);

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _pageActions = PrivateChatPageActions();
  final _service = PrivateChatService();

  bool _isSendingMedia = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = _pageActions.currentUserId;
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
        title: PrivateChatAppBarTitle(
          service: _service,
          peerId: peerId,
          fallbackName: widget.thread.name.trim().isNotEmpty
              ? widget.thread.name.trim()
              : 'Chat',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _service.watchMessages(chatId: chatId, myUserId: me),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Failed to load messages',
                        style: TextStyle(color: Colors.black45),
                      ),
                    );
                  }

                  final messages =
                      snapshot.data ?? const <PrivateChatMessageModel>[];

                  return PrivateChatMessagesList(
                    messages: messages,
                    scrollController: _scrollController,
                  );
                },
              ),
            ),
            PrivateChatComposer(
              chatId: chatId,
              peerId: peerId,
              controller: _controller,
              scrollController: _scrollController,
              isSendingMedia: _isSendingMedia,
              pageActions: _pageActions,
              setSendingMedia: (v) {
                if (!mounted) return;
                setState(() => _isSendingMedia = v);
              },
            ),
          ],
        ),
      ),
    );
  }
}
