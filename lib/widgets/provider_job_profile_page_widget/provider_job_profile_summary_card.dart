import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/provider_job_profile_model.dart';
import 'package:serbisyo_mobileapp/services/provider_job_profile_service.dart';
import 'package:serbisyo_mobileapp/widgets/app_elevated_card.dart';
import 'package:serbisyo_mobileapp/widgets/profile_page_widget/profile_section_title.dart';

import 'provider_job_profile_stat_card.dart';

class ProviderJobProfileSummaryCard extends StatelessWidget {
  static const primaryColor = Color(0xff254356);

  final ProviderJobProfileSummaryModel summary;
  final ProviderJobProfileService service;

  const ProviderJobProfileSummaryCard({
    super.key,
    required this.summary,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return AppElevatedCard(
      elevation: 6,
      borderRadius: 18,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionTitle(title: 'Summary'),
          const SizedBox(height: 12),
          ProviderJobProfileStatCard(
            icon: Icons.check_circle_outline,
            label: 'Jobs Finished',
            value: summary.completedJobs.toString(),
          ),
          const SizedBox(height: 10),
          ProviderJobProfileStatCard(
            icon: Icons.payments_outlined,
            label: 'Income',
            value: service.formatPeso(summary.income),
          ),
          const SizedBox(height: 10),
          ProviderJobProfileStatCard(
            icon: Icons.star_outline,
            label: 'Reviews',
            value: summary.ratingLabel,
          ),
        ],
      ),
    );
  }
}
