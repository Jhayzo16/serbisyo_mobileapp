import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serbisyo_mobileapp/models/job_model.dart';
import 'package:serbisyo_mobileapp/widgets/app_elevated_card.dart';

class JobPageCard extends StatelessWidget {
  const JobPageCard({
    super.key,
    required this.job,
    this.onViewDetails,
    this.onMessage,
    this.onCancel,
  });

  final JobModel job;
  final VoidCallback? onViewDetails;
  final VoidCallback? onMessage;
  final VoidCallback? onCancel;

  static const _primaryColor = Color(0xff254356);
  static const _mutedText = Color(0xff7C7979);
  static const _borderColor = Color(0xffD1D5DB);
  static const _actionBlue = Color(0xff2B88C1);
  static const _messageGrey = Color(0xff7C7979);

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

  Widget _customerName() {
    final direct = job.customerName.trim();
    if (direct.isNotEmpty) {
      return Text(
        direct,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _mutedText,
        ),
      );
    }

    if (job.userId.trim().isEmpty) {
      return const Text(
        'Customer',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _mutedText,
        ),
      );
    }

    final future = FirebaseFirestore.instance
        .collection('users')
        .doc(job.userId)
        .get();
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: future,
      builder: (context, snap) {
        final data = snap.data?.data();
        final first = (data?['firstName'] ?? '').toString().trim();
        final last = (data?['lastName'] ?? '').toString().trim();
        final full = [first, last].where((s) => s.isNotEmpty).join(' ');
        final name = full.isNotEmpty ? full : 'Customer';
        return Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _mutedText,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      height: 215,
      child: AppElevatedCard(
        elevation: 6,
        borderRadius: 12,
        borderSide: const BorderSide(color: _borderColor, width: 1),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageIcon(
                  AssetImage(job.iconAssetPath),
                  size: 26,
                  color: _mutedText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 20, color: _mutedText),
                const SizedBox(width: 8),
                Expanded(child: _customerName()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: _mutedText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDateTime(job.scheduledAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: _mutedText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: _mutedText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: _mutedText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: OutlinedButton(
                      onPressed: onViewDetails,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                const SizedBox(width: 8),
                SizedBox(
                  height: 28,
                  child: ElevatedButton(
                    onPressed: onMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _messageGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text(
                      'Message',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 28,
                  child: ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _actionBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text(
                      'Cancel Job',
                      maxLines: 1,
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
