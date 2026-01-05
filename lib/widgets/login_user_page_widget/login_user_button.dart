import 'package:flutter/material.dart';

class LoginUserButton extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;
  final bool isLoading;

  const LoginUserButton({
    super.key,
    this.onLogin,
    this.onSignUp,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2D6B7A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'LOGIN',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),

        SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Don\'t have an account? ',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            GestureDetector(
              onTap: isLoading ? null : onSignUp,
              child: Text(
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
