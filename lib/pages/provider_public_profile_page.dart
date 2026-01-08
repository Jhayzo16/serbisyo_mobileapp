import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/widgets/profile_page_widget/profile_section_title.dart';
import 'package:serbisyo_mobileapp/models/provider_public_profile_model.dart';
import 'package:serbisyo_mobileapp/services/provider_public_profile_service.dart';
import 'package:serbisyo_mobileapp/widgets/provider_public_profile_page_widget/provider_public_profile_header_card.dart';
import 'package:serbisyo_mobileapp/widgets/provider_public_profile_page_widget/provider_public_profile_review_card.dart';
import 'package:serbisyo_mobileapp/widgets/provider_public_profile_page_widget/provider_public_profile_stat_tile.dart';

class ProviderPublicProfilePage extends StatelessWidget {
  const ProviderPublicProfilePage({super.key, required this.providerId});

  final String providerId;

  static const _primaryColor = Color(0xff254356);
  static const _muted = Color(0xff7C7979);

  @override
  Widget build(BuildContext context) {
    final safeProviderId = providerId.trim();
    final bg = Color.lerp(Colors.white, _primaryColor, 0.06)!;
    final service = ProviderPublicProfileService();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'Provider Profile',
          style: TextStyle(fontWeight: FontWeight.w800, color: _primaryColor),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: safeProviderId.isEmpty
          ? const Center(
              child: Text(
                'No provider selected.',
                style: TextStyle(color: _muted),
              ),
            )
          : SafeArea(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: service.watchProvider(providerId: safeProviderId),
                builder: (context, providerSnap) {
                  final provider =
                      providerSnap.data?.data() ?? <String, dynamic>{};
                  final summary = service.summaryFromProviderData(provider);

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: service.watchProviderRequests(
                      providerId: safeProviderId,
                    ),
                    builder: (context, reqSnap) {
                      if (providerSnap.hasError || reqSnap.hasError) {
                        return const Center(
                          child: Text(
                            'Failed to load provider profile',
                            style: TextStyle(color: _muted),
                          ),
                        );
                      }

                      if (providerSnap.connectionState ==
                              ConnectionState.waiting ||
                          reqSnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = reqSnap.data?.docs ?? const [];
                      final stats = service.statsFromRequests(docs);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProviderPublicProfileHeaderCard(summary: summary),
                            const SizedBox(height: 14),
                            const ProfileSectionTitle(title: 'Stats'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ProviderPublicProfileStatTile(
                                    label: 'Jobs Finished',
                                    value: stats.finishedJobs.toString(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ProviderPublicProfileStatTile(
                                    label: 'Reviews',
                                    value: stats.reviewCount == 0
                                        ? '-'
                                        : '${stats.avgRating.toStringAsFixed(1)} (${service.formatWithCommas(stats.reviewCount.toString())})',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const ProfileSectionTitle(title: 'Review Comments'),
                            const SizedBox(height: 10),
                            if (stats.reviews.isEmpty)
                              const Text(
                                'No reviews yet',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            else
                              for (final ProviderPublicProfileReview r
                                  in stats.reviews)
                                ProviderPublicProfileReviewCard(
                                  service: service,
                                  review: r,
                                ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
