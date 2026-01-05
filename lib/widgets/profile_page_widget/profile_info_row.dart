import 'package:flutter/material.dart';

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  static const _primaryColor = Color(0xff254356);
  static const _muted = Color(0xff7C7979);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
        ),
      ],
    );
  }
}
