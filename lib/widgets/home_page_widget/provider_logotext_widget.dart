import 'package:flutter/material.dart';

class ProviderLogotextWidget extends StatelessWidget {
  const ProviderLogotextWidget({super.key});

  static const _primaryColor = Color(0xff254356);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 120,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned(
              right: 170,
              top: 75,
              child: Text(
                'Service Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: -10,
              child: Image.asset(
                'assets/icons/MascPeng.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}