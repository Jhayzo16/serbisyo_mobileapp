import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/notification_page.dart';
import 'package:serbisyo_mobileapp/pages/profile_page.dart';
import 'package:serbisyo_mobileapp/pages/your_request_page.dart';
import 'package:serbisyo_mobileapp/widgets/notification_bell_badge.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/home_widget.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/home_widget_category.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/home_widget_search.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _selectedColor = Color(0xff356785);
  static const _unselectedColor = Color(0xffBFBFBF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HomeWidget(),
              HomeWidgetSearch(),
              HomeWidgetCategory(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
            // Home (selected)
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
              ),
              child: ImageIcon(
                const AssetImage('assets/icons/home_icon.png'),
                color: Colors.white,
                size: 26,
              ),
            ),

            // Tasks
            GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => YourRequestPage()));
              },
              child: ImageIcon(
                const AssetImage('assets/icons/request_icon.png'),
                color: _unselectedColor,
                size: 26,
              ),
            ),

            // Chat
            GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ChatPage()));
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
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      actions: [
        Container(
          margin: EdgeInsets.only(top: 50, right: 20),
          child: NotificationBellBadge(
            iconSize: 40,
            iconColor: Colors.black,
            onPressed: () {
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationPage(isProvider: false),
                ),
              );
            },
          ),
        ),
      ],
      toolbarHeight: 100,
      title: Container(
        margin: EdgeInsets.only(top: 50, left: 20),
        child: Text(
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          'Hello, Higala!',
        ),
      ),
    );
  }
}
