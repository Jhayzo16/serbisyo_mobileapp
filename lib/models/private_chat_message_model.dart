enum PrivateChatMessageType { text, image }

class PrivateChatMessageModel {
  final PrivateChatMessageType type;
  final String text;
  final String imageUrl;
  final String senderId;
  final bool isMe;
  final DateTime createdAt;
  final String timeLabel;
  final bool showTime;

  const PrivateChatMessageModel({
    required this.type,
    required this.text,
    required this.imageUrl,
    required this.senderId,
    required this.isMe,
    required this.createdAt,
    required this.timeLabel,
    required this.showTime,
  });
}
