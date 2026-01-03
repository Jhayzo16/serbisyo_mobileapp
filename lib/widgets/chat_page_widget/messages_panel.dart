import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/message_thread_model.dart';
import 'package:serbisyo_mobileapp/pages/private_chat.dart';
import 'package:serbisyo_mobileapp/widgets/chat_page_widget/message_card.dart';

class MessagesPanel extends StatelessWidget {
  const MessagesPanel({super.key});

  List<MessageThreadModel> _threads() {
    return const [
      MessageThreadModel(
        name: 'Glener Guibone',
        messagePreview: 'Thank you for your service!',
        timeLabel: '14:32',
        unreadCount: 2,
        avatarAssetPath: 'assets/icons/Rosalinda.png',
      ),
      MessageThreadModel(
        name: 'Emmanuel Martos',
        messagePreview: 'Please dont mind the dogs',
        timeLabel: '12:32',
        unreadCount: 2,
        avatarAssetPath: 'assets/icons/Armando.png',
      ),
      MessageThreadModel(
        name: 'Lebron James',
        messagePreview: 'Hulata rako sa gawas sirr',
        timeLabel: '01:42',
        unreadCount: 2,
        avatarAssetPath: 'assets/icons/Corazon.png',
      ),
      MessageThreadModel(
        name: 'Jenny Wilson',
        messagePreview: 'Salamat boss!!',
        timeLabel: '01:22',
        unreadCount: 0,
        avatarAssetPath: 'assets/icons/MascPeng.png',
      ),
      MessageThreadModel(
        name: 'Annette Black',
        messagePreview: 'I would be very happy if you…',
        timeLabel: 'Mon, 22:23',
        unreadCount: 0,
        avatarAssetPath: 'assets/icons/Pelican.png',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final threads = _threads();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ListView.separated(
        itemCount: threads.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final thread = threads[index];
          return MessageCard(
            thread: thread,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PrivateChat(thread: thread)),
              );
            },
          );
        },
      ),
    );
  }
}
