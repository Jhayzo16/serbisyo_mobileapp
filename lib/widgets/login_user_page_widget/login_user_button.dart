import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/home_page.dart';

class LoginUserButton extends StatelessWidget {
  const LoginUserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to HomePage
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D6B7A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'LOGIN',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Don\'t have an account? ',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            GestureDetector(
              onTap: () {
                // TODO: navigate to sign up
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Color(0xFF25607A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
