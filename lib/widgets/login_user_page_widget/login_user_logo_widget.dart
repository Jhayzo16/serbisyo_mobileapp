import 'package:flutter/material.dart';

class LoginUserLogoWidget extends StatelessWidget {
  const LoginUserLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/icons/Pelican.png',
                width: 56,
                height: 56,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.red,
                  child: const Icon(Icons.error, color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Serbisyo',
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D6B7A),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // User / Provider selector inside the logo widget
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                const Text(
                  'User',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D6B7A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Color(0xFF2D6B7A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 28),
            Column(
              children: [
                const Text(
                  'Provider',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 11),
                const SizedBox(width: 40, height: 3),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
