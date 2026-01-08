import 'package:flutter/material.dart';

class PrivateChatTextBubble extends StatelessWidget {
  static const titleColor = Color(0xff254356);
  static const myBubbleColor = Color(0xff356785);
  static const theirBubbleColor = Color(0xffE9E9E9);

  final String text;
  final bool isMe;
  final String timeLabel;
  final bool showTime;

  const PrivateChatTextBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.timeLabel,
    required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? theirBubbleColor : myBubbleColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isMe ? titleColor : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (showTime)
                Text(
                  timeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: titleColor.withValues(alpha: 0.55),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
