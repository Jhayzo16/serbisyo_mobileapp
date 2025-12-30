import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/cleaning_services/cleaning_service_model.dart';

class CleaningServiceCards extends StatelessWidget {
  const CleaningServiceCards({
    super.key,
    required this.service,
    this.selected = false,
  });

  final CleaningServiceModel service;
  final bool selected;

  String _formatPeso(int amount) {
    final formatted = amount
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    return '₱$formatted';
  }

  List<Widget> _buildStars(double rating) {
    final clamped = rating.clamp(0.0, 5.0);
    final fullStars = clamped.floor();
    final hasHalf = (clamped - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    return [
      for (int i = 0; i < fullStars; i++)
        const Icon(Icons.star, size: 16, color: Colors.amber),
      if (hasHalf) const Icon(Icons.star_half, size: 16, color: Colors.amber),
      for (int i = 0; i < emptyStars; i++)
        const Icon(Icons.star_border, size: 16, color: Colors.amber),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xff356785) : Colors.black;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      width: 312,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: selected ? 1.2 : 1.0),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(service.icon, size: 40, color: Colors.grey.shade600),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff254356),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            service.duration,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                    children: [
                      const TextSpan(text: 'Starting at '),
                      TextSpan(
                        text: _formatPeso(service.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ..._buildStars(service.rating),
                    const SizedBox(width: 6),
                    Text(
                      service.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}