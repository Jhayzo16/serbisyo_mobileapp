import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/job_model.dart';
import 'package:serbisyo_mobileapp/models/message_thread_model.dart';
import 'package:serbisyo_mobileapp/pages/private_chat.dart';
import 'package:serbisyo_mobileapp/pages/view_more_details.dart';
import 'package:serbisyo_mobileapp/services/chat_service.dart';
import 'package:serbisyo_mobileapp/widgets/job_page_widget/job_page_card.dart';

class JobPageWidget extends StatelessWidget {
  const JobPageWidget({super.key, required this.showCompleted});

  final bool showCompleted;

  static const _promptBlue = Color(0xff2B88C1);

  Future<bool> _confirmCancelJob(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/Penguin_promot_icon.png',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 14),
              const Text(
                'Are you sure you want to cancel this job?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff7C7979),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff254356),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _promptBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  bool _matchesFilter(String status) {
    final normalized = status.trim();
    const completed = {'completed', 'done', 'cancelled', 'canceled'};
    if (showCompleted) return completed.contains(normalized);
    return !completed.contains(normalized);
  }

  void _openChat(BuildContext context, {required JobModel job}) {
    final me = FirebaseAuth.instance.currentUser?.uid;
    final peerId = job.userId.trim();
    if (me == null || peerId.isEmpty) return;

    final chat = ChatService();
    final chatId = chat.chatIdForUsers(userA: me, userB: peerId);
    if (chatId.trim().isEmpty) return;

    chat.ensureChat(chatId: chatId, participantIds: [me, peerId]);

    final thread = MessageThreadModel(
      name: job.customerName.trim().isNotEmpty
          ? job.customerName.trim()
          : 'Customer',
      messagePreview: '',
      timeLabel: '',
      unreadCount: 0,
      avatarAssetPath: 'assets/icons/profile_icon.png',
      chatId: chatId,
      peerId: peerId,
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PrivateChat(thread: thread)));
  }

  Future<void> _cancelJob(BuildContext context, {required JobModel job}) async {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(job.requestId)
          .set({
            'status': 'pending',
            'providerId': FieldValue.delete(),
            'acceptedAt': FieldValue.delete(),
            'cancelledAt': FieldValue.serverTimestamp(),
            'cancelledBy': me,
          }, SetOptions(merge: true));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to cancel job')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerId = FirebaseAuth.instance.currentUser?.uid;
    if (providerId == null) {
      return const Center(
        child: Text(
          'Please log in as a provider.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff7C7979),
          ),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('requests')
        .where('providerId', isEqualTo: providerId)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Failed to load jobs.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff7C7979),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          Timestamp? pickTs(QueryDocumentSnapshot<Map<String, dynamic>> d) {
            final data = d.data();
            if (showCompleted) {
              return (data['completedAt'] as Timestamp?) ??
                  (data['acceptedAt'] as Timestamp?) ??
                  (data['createdAtClient'] as Timestamp?) ??
                  (data['createdAt'] as Timestamp?);
            }
            return (data['acceptedAt'] as Timestamp?) ??
                (data['createdAtClient'] as Timestamp?) ??
                (data['createdAt'] as Timestamp?);
          }

          final aTs = pickTs(a) ?? Timestamp(0, 0);
          final bTs = pickTs(b) ?? Timestamp(0, 0);
          return bTs.compareTo(aTs);
        });

        final jobs = docs
            .map((doc) => JobModel.fromDoc(requestId: doc.id, data: doc.data()))
            .where((job) => _matchesFilter(job.status))
            .toList();

        if (jobs.isEmpty) {
          return Center(
            child: Text(
              showCompleted ? 'No completed jobs yet.' : 'No active jobs yet.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff7C7979),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(
            left: 30,
            right: 30,
            top: 14,
            bottom: 24,
          ),
          itemCount: jobs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return Align(
              alignment: Alignment.centerLeft,
              child: JobPageCard(
                job: job,
                onViewDetails: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ViewMoreDetails(
                        requestId: job.requestId,
                        isProviderView: true,
                      ),
                    ),
                  );
                },
                onMessage: () => _openChat(context, job: job),
                onCancel: () async {
                  final ok = await _confirmCancelJob(context);
                  if (!ok) return;
                  await _cancelJob(context, job: job);
                },
              ),
            );
          },
        );
      },
    );
  }
}
