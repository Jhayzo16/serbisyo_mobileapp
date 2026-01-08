import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/services/private_chat_page_actions.dart';

class PrivateChatComposer extends StatelessWidget {
  static const titleColor = Color(0xff254356);
  static const myBubbleColor = Color(0xff356785);
  static const inputFill = Color(0xffE9E9E9);

  final String chatId;
  final String peerId;
  final TextEditingController controller;
  final ScrollController scrollController;
  final bool isSendingMedia;
  final ValueSetter<bool> setSendingMedia;
  final PrivateChatPageActions pageActions;

  const PrivateChatComposer({
    super.key,
    required this.chatId,
    required this.peerId,
    required this.controller,
    required this.scrollController,
    required this.isSendingMedia,
    required this.setSendingMedia,
    required this.pageActions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: inputFill,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: isSendingMedia
                        ? null
                        : () => pageActions.pickAndSendImage(
                              context: context,
                              chatId: chatId,
                              peerId: peerId,
                              scrollController: scrollController,
                              isSendingMedia: isSendingMedia,
                              setSendingMedia: setSendingMedia,
                            ),
                    icon: const Icon(Icons.attach_file, color: titleColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => pageActions.sendText(
                        context: context,
                        chatId: chatId,
                        peerId: peerId,
                        controller: controller,
                        scrollController: scrollController,
                        isSendingMedia: isSendingMedia,
                      ),
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
            onTap: isSendingMedia
                ? null
                : () => pageActions.sendText(
                      context: context,
                      chatId: chatId,
                      peerId: peerId,
                      controller: controller,
                      scrollController: scrollController,
                      isSendingMedia: isSendingMedia,
                    ),
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: isSendingMedia
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, size: 28, color: myBubbleColor),
            ),
          ),
        ],
      ),
    );
  }
}
