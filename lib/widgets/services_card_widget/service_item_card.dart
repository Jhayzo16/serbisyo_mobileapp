import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';
import 'package:serbisyo_mobileapp/widgets/app_elevated_card.dart';

class ServiceItemCard extends StatelessWidget {
  const ServiceItemCard({
    super.key,
    required this.service,
    this.selected = false,
    this.onTap,
    this.compact = false,
  });

  final ServiceItemModel service;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  String _formatPeso(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    return '₱$formatted';
  }

  List<Widget> _buildStars(double rating) {
    final clamped = rating.clamp(0.0, 5.0);
    final fullStars = clamped.floor();
    final hasHalf = (clamped - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    Widget starIcon(IconData icon) {
      return SizedBox(
        width: 23,
        height: 18,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Icon(icon, size: 18, color: Colors.amber),
        ),
      );
    }

    return [
      for (int i = 0; i < fullStars; i++) starIcon(Icons.star),
      if (hasHalf) starIcon(Icons.star_half),
      for (int i = 0; i < emptyStars; i++) starIcon(Icons.star_border),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xff356785) : Colors.black;
    final horizontalMargin = compact ? 20.0 : 40.0;
    final horizontalPadding = compact ? 16.0 : 18.0;
    final verticalPadding = compact ? 12.0 : 18.0;
    final minHeight = compact ? 112.0 : 140.0;
    final titleSize = compact ? 14.0 : 16.0;
    final descSize = compact ? 11.0 : 12.0;
    final iconSize = compact ? 32.0 : 38.0;
    final iconBoxHeight = compact ? 32.0 : 38.0;
    final iconBoxWidth = compact ? 36.0 : 45.0;

    return GestureDetector(
      onTap: onTap,
      child: AppElevatedCard(
        elevation: 6,
        borderRadius: 14,
        borderSide: BorderSide(color: borderColor, width: selected ? 1.2 : 1.0),
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: iconBoxWidth,
                    height: iconBoxHeight,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(
                        service.icon,
                        size: iconSize,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: titleSize,
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
                            fontSize: descSize,
                            color: Color(0xff9B9B9B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xff9B9B9B),
                        ),
                        children: [
                          const TextSpan(
                            text: 'Starting at ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: _formatPeso(service.price),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        ..._buildStars(service.rating),
                        const SizedBox(width: 6),
                        Text(
                          service.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff9B9B9B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
