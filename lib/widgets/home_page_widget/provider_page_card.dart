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
    return AppElevatedCard(
      elevation: 3,
      borderRadius: 16,
      borderSide: const BorderSide(color: _borderColor, width: 1),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _primaryColor,
                  ),
                ),
              ),
              if (request.duration.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: _mutedText,
                ),
                const SizedBox(width: 4),
                Text(
                  request.duration,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _mutedText,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _mutedText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text(
                    'View details',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text(
                    'Accept',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
