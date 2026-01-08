import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/chat_peer_info_model.dart';
import 'package:serbisyo_mobileapp/services/private_chat_service.dart';

class PrivateChatAppBarTitle extends StatelessWidget {
  static const titleColor = Color(0xff254356);

  final PrivateChatService service;
  final String peerId;
  final String fallbackName;

  const PrivateChatAppBarTitle({
    super.key,
    required this.service,
    required this.peerId,
    required this.fallbackName,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatPeerInfoModel>(
      future: service.resolvePeerInfo(
        peerId: peerId,
        fallbackName: fallbackName,
      ),
      builder: (context, snap) {
        final info = snap.data;
        final name = (info?.name ?? fallbackName).trim();
        final photoUrl = (info?.photoUrl ?? '').trim();

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: const AssetImage('assets/icons/profile_icon.png'),
              foregroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                name.isNotEmpty ? name : 'Chat',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
