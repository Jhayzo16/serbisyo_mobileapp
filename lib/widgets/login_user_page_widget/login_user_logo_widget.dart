import 'package:flutter/material.dart';

class LoginUserLogoWidget extends StatefulWidget {
  LoginUserLogoWidget({super.key});

  @override
  State<LoginUserLogoWidget> createState() => _LoginUserLogoWidgetState();
}

class _LoginUserLogoWidgetState extends State<LoginUserLogoWidget> {
  bool _isUser = true;

  void _select(bool isUser) {
    if (_isUser == isUser) return;
    setState(() => _isUser = isUser);
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color(0xFF2D6B7A);
    final unselectedColor = Colors.grey;

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
                  child: Icon(Icons.error, color: Colors.white, size: 20),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
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

        SizedBox(height: 24),

      
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _select(true),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: _isUser ? 1.03 : 1.0),
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                child: Column(
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _isUser ? FontWeight.w700 : FontWeight.w600,
                        color: _isUser ? selectedColor : unselectedColor,
                      ),
                      child: Text('User'),
                    ),
                    SizedBox(height: 8),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: _isUser ? selectedColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 28),

            GestureDetector(
              onTap: () => _select(false),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: !_isUser ? 1.03 : 1.0),
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                child: Column(
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: !_isUser ? FontWeight.w700 : FontWeight.w600,
                        color: !_isUser ? selectedColor : unselectedColor,
                      ),
                      child: Text('Provider'),
                    ),
                    SizedBox(height: 8),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: !_isUser ? selectedColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
