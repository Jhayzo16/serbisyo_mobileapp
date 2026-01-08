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
  static const _messageGrey = Color(0xff7C7979);
  static const _actionBlue = Color(0xff2B88C1);
  static const _completedGreen = Color(0xff27AE60);
  static const _starYellow = Color(0xffF2C94C);

  bool get _isCompleted {
    const completed = {'completed', 'done', 'cancelled', 'canceled'};
    return completed.contains(job.status.trim());
  }

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

  String _formatDateOnly(DateTime dt) {
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

    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Widget _statusPill(String status) {
    final normalized = status.trim();
    final isCompleted = normalized == 'completed' || normalized == 'done';
    final label = normalized.isEmpty
        ? 'Completed'
        : '${normalized[0].toUpperCase()}${normalized.substring(1)}';

    final bg = isCompleted ? _completedGreen : _messageGrey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Widget> _buildStars(double rating) {
    final clamped = rating.clamp(0.0, 5.0);
    final fullStars = clamped.floor();
    final hasHalf = (clamped - fullStars) >= 0.5;

    final stars = <Widget>[];
    for (var i = 0; i < 5; i++) {
      IconData icon;
      Color color;
      if (i < fullStars) {
        icon = Icons.star;
        color = _starYellow;
      } else if (i == fullStars && hasHalf) {
        icon = Icons.star_half;
        color = _starYellow;
      } else {
        icon = Icons.star_border;
        color = _starYellow;
      }
      stars.add(Icon(icon, size: 18, color: color));
    }
    return stars;
  }

  Widget _customerAvatarAndName() {
    final direct = job.customerName.trim();
    if (job.userId.trim().isEmpty) {
      return Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: const AssetImage('assets/icons/profile_icon.png'),
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              direct.isNotEmpty ? direct : 'Customer',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _primaryColor,
              ),
            ),
          ),
        ],
      );
    }

    final future = FirebaseFirestore.instance.collection('users').doc(job.userId).get();
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: future,
      builder: (context, snap) {
        final data = snap.data?.data() ?? <String, dynamic>{};
        final first = (data['firstName'] ?? '').toString().trim();
        final last = (data['lastName'] ?? '').toString().trim();
        final full = [first, last].where((s) => s.isNotEmpty).join(' ');
        final name = full.isNotEmpty ? full : (direct.isNotEmpty ? direct : 'Customer');
        final photoUrl = (data['photoUrl'] ?? '').toString().trim();

        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: const AssetImage('assets/icons/profile_icon.png'),
              foregroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _completedCard() {
    final completedAt = job.completedAt ?? job.scheduledAt;

    return SizedBox(
      width: 380,
      child: AppElevatedCard(
        elevation: 6,
        borderRadius: 12,
        borderSide: const BorderSide(color: _borderColor, width: 1),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
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
            const SizedBox(height: 6),
            Text(
              'Completed on: ${_formatDateOnly(completedAt)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _mutedText,
              ),
            ),
            const SizedBox(height: 6),
            if (job.location.trim().isNotEmpty)
              Text(
                'Location: ${job.location.trim()}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _mutedText,
                ),
              ),
            const SizedBox(height: 6),
            if (job.duration.trim().isNotEmpty)
              Text(
                'Duration: ${job.duration.trim()}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _mutedText,
                ),
              ),
            const SizedBox(height: 14),
            const Text(
              'Customer:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            _customerAvatarAndName(),
            if (job.comment.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Comment:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _mutedText,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '“${job.comment.trim()}”',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _mutedText,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rating: ${job.rating.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _mutedText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(children: _buildStars(job.rating)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _mutedText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _statusPill(job.status),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    final showCancel = !_isCompleted && onCancel != null;

    if (_isCompleted) {
      return _completedCard();
    }

    return SizedBox(
      width: 380,
      height: 215,
      child: AppElevatedCard(
        elevation: 6,
        borderRadius: 12,
        borderSide: const BorderSide(color: _borderColor, width: 1),
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 18),
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
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  flex: showCancel ? 2 : 1,
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
                Expanded(
                  child: SizedBox(
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
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                if (showCancel) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        onPressed: onCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _actionBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Cancel Job',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
