import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/home_page.dart';
import 'package:serbisyo_mobileapp/pages/login_user_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins"
      ),
      home: LoginUserPage(),
    );
  }
}