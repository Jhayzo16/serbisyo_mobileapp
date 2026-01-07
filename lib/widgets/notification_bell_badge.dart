import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationBellBadge extends StatelessWidget {
  const NotificationBellBadge({
    super.key,
    required this.onPressed,
    this.iconColor,
    this.iconSize,
  });

  final VoidCallback onPressed;
  final Color? iconColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.notifications,
          color: iconColor,
          size: iconSize,
        ),
      );
    }

    final unreadStream = FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: unreadStream,
      builder: (context, snapshot) {
        final unreadCount = snapshot.data?.docs.length ?? 0;

        return IconButton(
          onPressed: onPressed,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications,
                color: iconColor,
                size: iconSize,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
