import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/private_chat_message_model.dart';

import 'private_chat_image_bubble.dart';
import 'private_chat_text_bubble.dart';

class PrivateChatMessagesList extends StatelessWidget {
  final List<PrivateChatMessageModel> messages;
  final ScrollController scrollController;

  const PrivateChatMessagesList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        if (message.type == PrivateChatMessageType.image &&
            message.imageUrl.isNotEmpty) {
          return PrivateChatImageBubble(
            imageUrl: message.imageUrl,
            isMe: message.isMe,
            timeLabel: message.timeLabel,
            showTime: message.showTime,
          );
        }

        return PrivateChatTextBubble(
          text: message.text,
          isMe: message.isMe,
          timeLabel: message.timeLabel,
          showTime: message.showTime,
        );
      },
    );
  }
}
