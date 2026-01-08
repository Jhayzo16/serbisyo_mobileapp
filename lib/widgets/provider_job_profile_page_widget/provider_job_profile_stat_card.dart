import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/widgets/app_elevated_card.dart';

class ProviderJobProfileStatCard extends StatelessWidget {
  static const primaryColor = Color(0xff254356);
  static const fieldFill = Color(0xFFF3F4F6);
  static const muted = Color(0xff7C7979);
  static const borderColor = Color(0xffD1D5DB);

  final IconData icon;
  final String label;
  final String value;

  const ProviderJobProfileStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AppElevatedCard(
      elevation: 2,
      borderRadius: 14,
      borderSide: const BorderSide(color: borderColor, width: 1),
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: fieldFill,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
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
                    color: muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
