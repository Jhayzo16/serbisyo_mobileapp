import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/widgets/profile_page_widget/profile_section_title.dart';
import 'package:serbisyo_mobileapp/services/provider_job_profile_service.dart';
import 'package:serbisyo_mobileapp/widgets/provider_job_profile_page_widget/provider_job_profile_review_card.dart';
import 'package:serbisyo_mobileapp/widgets/provider_job_profile_page_widget/provider_job_profile_summary_card.dart';

class ProviderJobProfilePage extends StatelessWidget {
  const ProviderJobProfilePage({super.key});

  static const _primaryColor = Color(0xff254356);
  static const _muted = Color(0xff7C7979);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final service = ProviderJobProfileService();
    final bg = Color.lerp(Colors.white, _primaryColor, 0.06)!;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Job Profile',
          style: TextStyle(fontWeight: FontWeight.w800, color: _primaryColor),
        ),
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(
              child: Text(
                'Please log in.',
                style: TextStyle(color: Colors.black45),
              ),
            )
          : SafeArea(
              child: StreamBuilder(
                stream: service.watchRequestsForProvider(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Failed to load job profile',
                        style: TextStyle(color: _muted),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? const [];
                  final summary = service.buildSummary(docs);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProviderJobProfileSummaryCard(
                          summary: summary,
                          service: service,
                        ),
                        const SizedBox(height: 18),
                        const ProfileSectionTitle(title: 'Reviews'),
                        const SizedBox(height: 10),
                        if (summary.reviews.isEmpty)
                          const Text(
                            'No reviews yet',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          for (final r in summary.reviews)
                            ProviderJobProfileReviewCard(
                              review: r,
                              service: service,
                            ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
