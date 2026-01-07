import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/jobs_page.dart';
import 'package:serbisyo_mobileapp/pages/notification_page.dart';
import 'package:serbisyo_mobileapp/pages/profile_page.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/provider_page_widget.dart';
import 'package:serbisyo_mobileapp/widgets/notification_bell_badge.dart';

class ProviderHomepage extends StatelessWidget {
  const ProviderHomepage({super.key});

  static const _primaryColor = Color(0xff254356);
  static const _selectedColor = Color(0xff356785);
  static const _unselectedColor = Color(0xffBFBFBF);

  @override
  Widget build(BuildContext context) {
    final bg = Color.lerp(Colors.white, _selectedColor, 0.12)!;
    return Scaffold(
      backgroundColor: bg,
      appBar: appBar(context),
      bottomNavigationBar: navToolbar(context),
      body: const ProviderPageWidget(themeBlue: _selectedColor),
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
                MaterialPageRoute(
                  builder: (_) => const ChatPage(isProvider: true),
                ),
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

  AppBar appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: NotificationBellBadge(
            iconSize: 32,
            iconColor: Colors.black,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationPage(isProvider: true),
                ),
              );
            },
          ),
        ),
      ],
      toolbarHeight: 72,
      titleSpacing: 20,
      title: const Text(
        'Earn Money Now!',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 22,
          color: _primaryColor,
        ),
      ),
    );
  }
}
