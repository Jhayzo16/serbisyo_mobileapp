import 'package:flutter/material.dart';

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle({super.key, required this.title});

  final String title;

  static const _primaryColor = Color(0xff254356);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: _primaryColor,
      ),
    );
  }
}
