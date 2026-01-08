import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/widgets/app_elevated_card.dart';

class ProviderPublicProfileStatTile extends StatelessWidget {
  const ProviderPublicProfileStatTile({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  static const _primaryColor = Color(0xff254356);
  static const _muted = Color(0xff7C7979);
  static const _borderColor = Color(0xffD1D5DB);

  @override
  Widget build(BuildContext context) {
    return AppElevatedCard(
      elevation: 2,
      borderRadius: 14,
      borderSide: const BorderSide(color: _borderColor, width: 1),
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
