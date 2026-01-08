import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/services/private_chat_actions.dart';

class PrivateChatPageActions {
  PrivateChatPageActions({PrivateChatActions? actions})
    : _actions = actions ?? PrivateChatActions();

  final PrivateChatActions _actions;

  String? get currentUserId => _actions.currentUserId;

  Future<void> sendText({
    required BuildContext context,
    required String chatId,
    required String peerId,
    required TextEditingController controller,
    required ScrollController scrollController,
    required bool isSendingMedia,
  }) async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    if (isSendingMedia) return;

    final senderId = currentUserId;
    final id = chatId.trim();
    final peer = peerId.trim();
    if (senderId == null || id.isEmpty || peer.isEmpty) return;

    controller.clear();

    try {
      await _actions.sendText(chatId: id, peerId: peer, text: text);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
      return;
    }

    _scrollToBottom(scrollController);
  }

  Future<void> pickAndSendImage({
    required BuildContext context,
    required String chatId,
    required String peerId,
    required ScrollController scrollController,
    required bool isSendingMedia,
    required ValueSetter<bool> setSendingMedia,
  }) async {
    if (isSendingMedia) return;

    final senderId = currentUserId;
    final id = chatId.trim();
    final peer = peerId.trim();
    if (senderId == null || id.isEmpty || peer.isEmpty) return;

    setSendingMedia(true);

    try {
      await _actions.pickAndSendImage(chatId: id, peerId: peer);
      _scrollToBottom(scrollController);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send photo')));
    } finally {
      if (!context.mounted) return;
      setSendingMedia(false);
    }
  }

  void _scrollToBottom(ScrollController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }
}
