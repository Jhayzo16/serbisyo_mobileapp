import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';

class ServiceRequestSummaryCard extends StatelessWidget {
  final ServiceItemModel service;
  final String Function(int amount) formatPeso;

  const ServiceRequestSummaryCard({
    super.key,
    required this.service,
    required this.formatPeso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 40, right: 40),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF6F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff254356),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Starting at ${formatPeso(service.price)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff9B9B9B),
              fontWeight: FontWeight.w500,
            ),
          ),
          if ((service.duration ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: Color(0xff9B9B9B),
                ),
                const SizedBox(width: 8),
                Text(
                  service.duration!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff9B9B9B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
