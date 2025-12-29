import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/widgets/login_user_page_widget/login_user_button.dart';
import 'package:serbisyo_mobileapp/widgets/login_user_page_widget/login_user_field.dart';
import 'package:serbisyo_mobileapp/widgets/login_user_page_widget/login_user_logo_widget.dart';
import 'package:serbisyo_mobileapp/widgets/login_user_page_widget/login_user_field.dart';

class LoginUserPage extends StatelessWidget {
  const LoginUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                Center(child: LoginUserLogoWidget()),
                SizedBox(height: 24),
                LoginUserFields(),
                LoginUserButton(),

               
              ],
            ),
          ),
        ),
      ),
    );
  }
}
