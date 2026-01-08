import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/services/provider_public_profile_service.dart';

class ProviderPublicProfileReviewerRow extends StatelessWidget {
  const ProviderPublicProfileReviewerRow({
    super.key,
    required this.service,
    required this.customerId,
    required this.fallbackName,
  });

  final ProviderPublicProfileService service;
  final String customerId;
  final String fallbackName;

  static const _primaryColor = Color(0xff254356);

  @override
  Widget build(BuildContext context) {
    final safeFallbackName = fallbackName.trim();
    final safeCustomerId = customerId.trim();

    Widget buildRow({required String name, required String photoUrl}) {
      final safeName = name.trim().isNotEmpty ? name.trim() : 'Customer';
      final safePhoto = photoUrl.trim();
      return Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: const AssetImage('assets/icons/profile_icon.png'),
            foregroundImage: safePhoto.isNotEmpty
                ? NetworkImage(safePhoto)
                : null,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              safeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _primaryColor,
              ),
            ),
          ),
        ],
      );
    }

    if (safeCustomerId.isEmpty) {
      return buildRow(name: safeFallbackName, photoUrl: '');
    }

    return FutureBuilder(
      future: service.loadReviewerInfo(customerId: safeCustomerId),
      builder: (context, snap) {
        final info = snap.data;
        final name = (info?.name ?? '').trim();
        final photoUrl = (info?.photoUrl ?? '').trim();

        return buildRow(
          name: name.isNotEmpty ? name : safeFallbackName,
          photoUrl: photoUrl,
        );
      },
    );
  }
}
