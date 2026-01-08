import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/provider_public_profile_model.dart';
import 'package:serbisyo_mobileapp/widgets/app_elevated_card.dart';

class ProviderPublicProfileHeaderCard extends StatelessWidget {
  const ProviderPublicProfileHeaderCard({super.key, required this.summary});

  final ProviderPublicProfileSummary summary;

  static const _primaryColor = Color(0xff254356);
  static const _muted = Color(0xff7C7979);

  @override
  Widget build(BuildContext context) {
    final name = summary.name.trim();
    final jobTitle = summary.jobTitle.trim();
    final photoUrl = summary.photoUrl.trim();

    return AppElevatedCard(
      elevation: 6,
      borderRadius: 18,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: const AssetImage('assets/icons/profile_icon.png'),
            foregroundImage: photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Provider',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _primaryColor,
                  ),
                ),
                if (jobTitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    jobTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
