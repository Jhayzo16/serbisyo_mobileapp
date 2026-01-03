import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/your_request_page.dart';
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
      appBar: appBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [HomeWidget(), HomeWidgetSearch(), HomeWidgetCategory()],
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
            ImageIcon(
              const AssetImage('assets/icons/profile_icon.png'),
              color: _unselectedColor,
              size: 26,
            ),
          ],
        ),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          'Hello, Higala!',
        ),
      ),
    );
  }
}
