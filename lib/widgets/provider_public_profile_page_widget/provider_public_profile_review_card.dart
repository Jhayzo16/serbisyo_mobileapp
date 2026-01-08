import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/provider_public_profile_model.dart';
import 'package:serbisyo_mobileapp/services/provider_public_profile_service.dart';
import 'package:serbisyo_mobileapp/widgets/app_elevated_card.dart';
import 'package:serbisyo_mobileapp/widgets/provider_public_profile_page_widget/provider_public_profile_reviewer_row.dart';

class ProviderPublicProfileReviewCard extends StatelessWidget {
  const ProviderPublicProfileReviewCard({
    super.key,
    required this.service,
    required this.review,
  });

  final ProviderPublicProfileService service;
  final ProviderPublicProfileReview review;

  static const _primaryColor = Color(0xff254356);
  static const _muted = Color(0xff7C7979);
  static const _borderColor = Color(0xffD1D5DB);

  @override
  Widget build(BuildContext context) {
    final comment = review.comment.trim();

    return AppElevatedCard(
      elevation: 2,
      borderRadius: 14,
      borderSide: const BorderSide(color: _borderColor),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProviderPublicProfileReviewerRow(
            service: service,
            customerId: review.customerId,
            fallbackName: review.customerName,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xffF2C94C)),
                  const SizedBox(width: 6),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
              if (review.ratedAt != null)
                Text(
                  service.formatShortDate(review.ratedAt!),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.isNotEmpty ? '“$comment”' : 'No comment',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }
}
