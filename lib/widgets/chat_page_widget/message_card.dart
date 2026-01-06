import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/message_thread_model.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.thread, this.onTap});

  final MessageThreadModel thread;
  final VoidCallback? onTap;

  static const _titleColor = Colors.black;
  static const _subtitleColor = Color(0xff9B9B9B);
  static const _badgeColor = Color(0xffe11d48);

  @override
  Widget build(BuildContext context) {
    final avatarUrl = thread.avatarUrl.trim();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: AssetImage(thread.avatarAssetPath),
              foregroundImage:
                  avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.messagePreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  thread.timeLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _subtitleColor,
                  ),
                ),
                const SizedBox(height: 10),
                if (thread.hasUnread)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: _badgeColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${thread.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
