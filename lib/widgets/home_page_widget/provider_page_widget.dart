import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serbisyo_mobileapp/models/provider_request_model.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/provider_page_card.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/provider_logotext_widget.dart';

class ProviderPageWidget extends StatelessWidget {
  const ProviderPageWidget({super.key});

  static const _mutedText = Color(0xff7C7979);

  Future<void> _acceptRequest(BuildContext context, {required String requestId}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('requests').doc(requestId).set({
        'status': 'inProgress',
        'providerId': uid,
        'acceptedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to accept request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const ProviderLogotextWidget(),
          const SizedBox(height: 8),
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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data?.docs ?? const [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No service requests yet',
                      style: TextStyle(color: _mutedText),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final request = ProviderRequestModel.fromDoc(
                      requestId: doc.id,
                      data: doc.data(),
                    );

                    return Center(
                      child: ProviderPageCard(
                        request: request,
                        onViewDetails: () {},
                        onAccept: () => _acceptRequest(
                          context,
                          requestId: request.requestId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}