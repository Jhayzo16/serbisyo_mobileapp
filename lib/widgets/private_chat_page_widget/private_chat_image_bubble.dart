import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/widgets/chat_page_widget/full_screen_image_page.dart';

class PrivateChatImageBubble extends StatelessWidget {
  static const titleColor = Color(0xff254356);

  final String imageUrl;
  final bool isMe;
  final String timeLabel;
  final bool showTime;

  const PrivateChatImageBubble({
    super.key,
    required this.imageUrl,
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
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullScreenImagePage(imageUrl: imageUrl),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) {
                      return Container(
                        height: 180,
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    },
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
