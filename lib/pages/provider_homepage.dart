import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/jobs_page.dart';
import 'package:serbisyo_mobileapp/pages/profile_page.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/provider_page_widget.dart';

class ProviderHomepage extends StatelessWidget {
  const ProviderHomepage({super.key});

   static const _primaryColor = Color(0xff254356);
  static const _selectedColor = Color(0xff356785);
  static const _unselectedColor = Color(0xffBFBFBF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      bottomNavigationBar: navToolbar(context),
      body: ProviderPageWidget()
    );
  }

  Container navToolbar(BuildContext context) {
    return Container(
      height: 86,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 12,
          offset: Offset(0, -6),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Provider Home (selected)
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _selectedColor,
            shape: BoxShape.circle,
          ),
          child: ImageIcon(
            const AssetImage('assets/icons/provider_home_icon.png'),
            color: Colors.white,
            size: 26,
          ),
        ),

        // Your Jobs
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const JobsPage()),
            );
          },
          child: ImageIcon(
            const AssetImage('assets/icons/your_jobs_icon.png'),
            color: _unselectedColor,
            size: 26,
          ),
        ),

        // Chat
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ChatPage(isProvider: true)),
            );
          },
          child: ImageIcon(
            const AssetImage('assets/icons/message_icon.png'),
            color: _unselectedColor,
            size: 26,
          ),
        ),

        // Profile
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfilePage(isProvider: true)),
            );
          },
          child: ImageIcon(
            const AssetImage('assets/icons/profile_icon.png'),
            color: _unselectedColor,
            size: 26,
          ),
        ),
      ],
    ),
    );
  }

  AppBar appBar() {
    return AppBar(
      actions: [
      Container(
        margin: EdgeInsets.only(top: 50, right: 20),
        child: Icon(size: 40, color: Colors.black, Icons.notifications),
      ),
    ],
    toolbarHeight: 100,
    title: Container(
      margin: EdgeInsets.only(top: 50, left: 20),
      child: Text(
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        'Earn Money Now!',
      ),
    ),
    );
  }
}