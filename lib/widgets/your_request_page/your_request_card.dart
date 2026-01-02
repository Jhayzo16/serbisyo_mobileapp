import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/your_request_model.dart';

class YourRequestCard extends StatelessWidget {
  const YourRequestCard({
    super.key,
    required this.request,
    this.onViewDetails,
    this.onCancel,
    this.onRateProvider,
    this.onBookAgain,
  });

  final YourRequestModel request;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCancel;
  final VoidCallback? onRateProvider;
  final VoidCallback? onBookAgain;

  static const _buttonColor = Color(0xff2B88C1);
  static const _workInProgressColor = Color(0xffF2C94C);
  static const _completedColor = Color(0xff27AE60);
  static const _primaryColor = Color(0xff356785);
  static const _titleColor = Color(0xff254356);
  static const _mutedText = Color(0xff7C7979);

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

  Widget _metaRow({
    required IconData icon,
    required String label,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _mutedText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              color: _mutedText,
              
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProvider = request.provider != null;
    final isPending = request.status == RequestStatus.pending;
    final isInProgress = request.status == RequestStatus.inProgress;
    final isCompleted = request.status == RequestStatus.completed;

    final cardHeight = switch (request.status) {
      RequestStatus.pending => 150.0,
      RequestStatus.inProgress => 252.0,
      RequestStatus.completed => 330.0,
    };

    return Center(
      child: SizedBox(
        width: 311,
        height: cardHeight,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black38, width: 0.9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageIcon(
                    AssetImage(request.iconAssetPath),
                    size: 22,
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
                        color: _titleColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _metaRow(
                icon: Icons.calendar_month,
                label: _formatDateTime(request.scheduledAt),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              if (request.location != null) ...[
                const SizedBox(height: 4),
                _metaRow(
                  icon: Icons.location_on,
                  label: request.location!,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ],
              if (isCompleted && request.location != null && hasProvider)
                const SizedBox(height: 40),
              if (hasProvider) ...[
                const SizedBox(height: 6),
                const Text(
                  'Provider:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(
                        request.provider!.avatarAssetPath,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.provider!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _titleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Color(0xffF2C94C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${request.provider!.rating.toStringAsFixed(1)} (${request.provider!.reviewCount} Reviews)',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: _mutedText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (isCompleted && request.duration != null) ...[
                const SizedBox(height: 10),
                _metaRow(
                  icon: Icons.schedule,
                  label: 'Duration: ${request.duration!}',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ],
              if (isCompleted && request.totalPaid != null) ...[
                const SizedBox(height: 4),
                _metaRow(
                  icon: Icons.payments_outlined,
                  label: 'Total Paid: ${request.totalPaid!}',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ],
              const Spacer(),
              if (!isCompleted)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: OutlinedButton(
                          onPressed: onViewDetails,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'View Details',
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: onCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInProgress
                                ? _workInProgressColor
                                : _buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          child: Text(
                            isInProgress
                                ? 'Work In Progress'
                                : (isPending ? 'Cancel Request' : ''),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: OutlinedButton(
                          onPressed: onRateProvider,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Rate Provider',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
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
                        height: 30,
                        child: OutlinedButton(
                          onPressed: onBookAgain,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Book Again',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
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
                        height: 30,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _completedColor,
                            disabledBackgroundColor: _completedColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          child: const Text(
                            'Completed',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
