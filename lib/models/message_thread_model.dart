class MessageThreadModel {
  final String name;
  final String messagePreview;
  final String timeLabel;
  final int unreadCount;
  final String avatarAssetPath;
  final String avatarUrl;
  final String chatId;
  final String peerId;

  const MessageThreadModel({
    required this.name,
    required this.messagePreview,
    required this.timeLabel,
    required this.unreadCount,
    required this.avatarAssetPath,
    this.avatarUrl = '',
    this.chatId = '',
    this.peerId = '',
  });

  bool get hasUnread => unreadCount > 0;
}
