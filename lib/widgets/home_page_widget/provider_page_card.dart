import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/provider_request_model.dart';
import 'package:serbisyo_mobileapp/widgets/app_elevated_card.dart';

class ProviderPageCard extends StatelessWidget {
  const ProviderPageCard({
    super.key,
    required this.request,
    this.onViewDetails,
    this.onAccept,
  });

  final ProviderRequestModel request;
  final VoidCallback? onViewDetails;
  final VoidCallback? onAccept;

  static const _primaryColor = Color(0xff254356);
  static const _mutedText = Color(0xff7C7979);
  static const _buttonColor = Color(0xff2B88C1);
  static const _borderColor = Color(0xffD1D5DB);

  String _formatDateTime(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, $hour12:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 172,
      child: AppElevatedCard(
        elevation: 6,
        borderRadius: 12,
        borderSide: const BorderSide(color: _borderColor, width: 1),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageIcon(
                  AssetImage(request.iconAssetPath),
                  size: 20,
                  color: _mutedText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    request.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),
                if (request.duration.trim().isNotEmpty) ...[
                  const Icon(
                    Icons.access_time_outlined,
                    size: 14,
                    color: _mutedText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.duration,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _mutedText,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: _mutedText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _mutedText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: _mutedText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDateTime(request.scheduledAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _mutedText,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 30,
                    child: OutlinedButton(
                      onPressed: onViewDetails,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text(
                        'View More Details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 128,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      'Accept Request',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
