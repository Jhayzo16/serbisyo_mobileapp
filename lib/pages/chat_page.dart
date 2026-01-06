import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/home_page.dart';
import 'package:serbisyo_mobileapp/pages/jobs_page.dart';
import 'package:serbisyo_mobileapp/pages/notification_page.dart';
import 'package:serbisyo_mobileapp/pages/profile_page.dart';
import 'package:serbisyo_mobileapp/pages/provider_homepage.dart';
import 'package:serbisyo_mobileapp/pages/your_request_page.dart';
import 'package:serbisyo_mobileapp/widgets/chat_page_widget/messages_panel.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, this.isProvider = false});

  final bool isProvider;

  static const _primaryColor = Color(0xff254356);
  static const _selectedColor = Color(0xff356785);
  static const _unselectedColor = Color(0xffBFBFBF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      bottomNavigationBar: navToolBar(context),
      body: MessagesPanel(),
    );
  }

  Container navToolBar(BuildContext context) {
    if (isProvider) {
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
            // Provider Home
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ProviderHomepage()),
                );
              },
              child: ImageIcon(
                const AssetImage('assets/icons/provider_home_icon.png'),
                color: _unselectedColor,
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

            // Chat (selected)
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
              ),
              child: ImageIcon(
                const AssetImage('assets/icons/message_icon.png'),
                color: Colors.white,
                size: 26,
              ),
            ),

            // Profile
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const ProfilePage(isProvider: true),
                  ),
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
          // Home
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            },
            child: ImageIcon(
              const AssetImage('assets/icons/home_icon.png'),
              color: _unselectedColor,
              size: 26,
            ),
          ),
          // Tasks
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const YourRequestPage()),
              );
            },
            child: ImageIcon(
              const AssetImage('assets/icons/request_icon.png'),
              color: _unselectedColor,
              size: 26,
            ),
          ),

          // Chat
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _selectedColor,
              shape: BoxShape.circle,
            ),
            child: ImageIcon(
              const AssetImage('assets/icons/message_icon.png'),
              color: Colors.white,
              size: 26,
            ),
          ),

          // Profile
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
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

  AppBar appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [
        Container(
          margin: EdgeInsets.only(top: 50, right: 20),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NotificationPage(isProvider: isProvider),
                ),
              );
            },
            icon: const Icon(
              size: 40,
              color: Colors.black,
              Icons.notifications,
            ),
          ),
        ),
      ],
      toolbarHeight: 100,
      title: Container(
        margin: EdgeInsets.only(top: 50, left: 20),
        child: Text(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _primaryColor,
            fontSize: 40,
          ),
          'Messages',
        ),
      ),
    );
  }
}
