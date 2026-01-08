import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serbisyo_mobileapp/models/provider_request_model.dart';
import 'package:serbisyo_mobileapp/pages/view_more_details.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/provider_page_card.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/provider_logotext_widget.dart';

class ProviderPageWidget extends StatelessWidget {
  const ProviderPageWidget({super.key, required this.themeBlue});

  final Color themeBlue;

  static const _mutedText = Color(0xff7C7979);
  static const _promptBlue = Color(0xff2B88C1);

  Future<bool> _confirmAcceptRequest(BuildContext context) async {
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
                'Accept this Job?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _mutedText,
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

  Future<void> _acceptRequestWithConfirm(
    BuildContext context, {
    required String requestId,
  }) async {
    final ok = await _confirmAcceptRequest(context);
    if (!ok) return;
    if (!context.mounted) return;
    await _acceptRequest(context, requestId: requestId);
  }

  Future<void> _acceptRequest(
    BuildContext context, {
    required String requestId,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final db = FirebaseFirestore.instance;
      final reqRef = db.collection('requests').doc(requestId);
      final notifRef = db.collection('notifications').doc();

      await db.runTransaction((tx) async {
        final snap = await tx.get(reqRef);
        final data = snap.data() as Map<String, dynamic>?;
        final userId = (data?['userId'] ?? '').toString().trim();

        tx.set(reqRef, {
          'status': 'inProgress',
          'providerId': uid,
          'acceptedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (userId.isEmpty) return;

        String serviceName = '';
        final service = data?['service'];
        if (service is Map) {
          serviceName = (service['name'] ?? '').toString().trim();
        }
        if (serviceName.isEmpty) {
          serviceName = (data?['title'] ?? data?['type'] ?? '')
              .toString()
              .trim();
        }

        final body = serviceName.isNotEmpty
            ? 'Your request for $serviceName has been accepted!'
            : 'Your request has been accepted!';

        tx.set(notifRef, {
          'recipientId': userId,
          'senderId': uid,
          'type': 'requestAccepted',
          'title': 'Serbisyo',
          'body': body,
          'requestId': requestId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
          'createdAtClient': Timestamp.now(),
        });
      });
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to accept request')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final surfaceTint = Color.lerp(Colors.white, themeBlue, 0.06)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 70, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceTint,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              const ProviderLogotextWidget(
                padding: EdgeInsets.fromLTRB(20, 10, 16, 6),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: db
                      .collection('requests')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Failed to load requests',
                          style: TextStyle(color: _mutedText),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = (snapshot.data?.docs ?? const []).toList()
                      ..sort((a, b) {
                        final aTs =
                            (a.data()['createdAtClient'] as Timestamp?) ??
                            (a.data()['createdAt'] as Timestamp?) ??
                            Timestamp(0, 0);
                        final bTs =
                            (b.data()['createdAtClient'] as Timestamp?) ??
                            (b.data()['createdAt'] as Timestamp?) ??
                            Timestamp(0, 0);
                        return bTs.compareTo(aTs);
                      });
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No service requests yet',
                          style: TextStyle(color: _mutedText),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final request = ProviderRequestModel.fromDoc(
                          requestId: doc.id,
                          data: doc.data(),
                        );

                        return ProviderPageCard(
                          request: request,
                          onViewDetails: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ViewMoreDetails(
                                  requestId: request.requestId,
                                  isProviderView: true,
                                ),
                              ),
                            );
                          },
                          onAccept: () => _acceptRequestWithConfirm(
                            context,
                            requestId: request.requestId,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
