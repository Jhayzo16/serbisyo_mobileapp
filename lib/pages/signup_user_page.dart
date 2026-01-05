import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/widgets/login_user_page_widget/signup_user_widget.dart';

class SignupUserPage extends StatelessWidget {
  const SignupUserPage({super.key});

  static const _brandColor = Color(0xFF2D6B7A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(context),
      body: SignupUserWidget(
        
      ),
      
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons/Pelican.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        const Text(
          'Serbisyo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _brandColor,
          ),
        ),
      ],
    ),
    );
  }
}