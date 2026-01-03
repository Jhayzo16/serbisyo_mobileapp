class MessageThreadModel {
  final String name;
  final String messagePreview;
  final String timeLabel;
  final int unreadCount;
  final String avatarAssetPath;

  const MessageThreadModel({
    required this.name,
    required this.messagePreview,
    required this.timeLabel,
    required this.unreadCount,
    required this.avatarAssetPath,
  });

  bool get hasUnread => unreadCount > 0;
}
