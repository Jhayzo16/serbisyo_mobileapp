import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/provider_job_profile_model.dart';
import 'package:serbisyo_mobileapp/services/provider_job_profile_service.dart';
import 'package:serbisyo_mobileapp/widgets/app_elevated_card.dart';

class ProviderJobProfileReviewCard extends StatelessWidget {
  static const primaryColor = Color(0xff254356);
  static const muted = Color(0xff7C7979);
  static const borderColor = Color(0xffD1D5DB);

  final ProviderJobProfileReviewModel review;
  final ProviderJobProfileService service;

  const ProviderJobProfileReviewCard({
    super.key,
    required this.review,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return AppElevatedCard(
      elevation: 2,
      borderRadius: 14,
      borderSide: const BorderSide(color: borderColor),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: FutureBuilder<CustomerDisplayInfoModel>(
        future: service.resolveCustomerInfo(
          customerId: review.customerId,
          customerNameFallback: review.customerNameFallback,
        ),
        builder: (context, snap) {
          final info =
              snap.data ??
              CustomerDisplayInfoModel(
                name: review.customerNameFallback.trim().isNotEmpty
                    ? review.customerNameFallback.trim()
                    : 'Customer',
                photoUrl: '',
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: const AssetImage(
                      'assets/icons/profile_icon.png',
                    ),
                    foregroundImage: info.photoUrl.isNotEmpty
                        ? NetworkImage(info.photoUrl)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      info.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xffF2C94C),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        review.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
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
                        color: muted,
                      ),
                    ),
                ],
              ),
              if (review.comment.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '“${review.comment.trim()}”',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
