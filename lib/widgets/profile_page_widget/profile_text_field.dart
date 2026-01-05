import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.enabled,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType keyboardType;

  static const _primaryColor = Color(0xff254356);
  static const _fieldFill = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: _fieldFill,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}
