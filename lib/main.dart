import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:serbisyo_mobileapp/firebase_options.dart';
import 'package:serbisyo_mobileapp/pages/login_user_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // On Android, the google-services plugin provides the native Firebase options.
    // Passing manual options here can trigger [core/duplicate-app] when a default
    // native app already exists (common during hot restart).
    await Firebase.initializeApp();
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }
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