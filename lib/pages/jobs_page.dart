import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/notification_page.dart';
import 'package:serbisyo_mobileapp/pages/profile_page.dart';
import 'package:serbisyo_mobileapp/pages/provider_homepage.dart';
import 'package:serbisyo_mobileapp/widgets/job_page_widget/job_page_widget.dart';
import 'package:serbisyo_mobileapp/widgets/job_page_widget/job_tab_switcher.dart';
import 'package:serbisyo_mobileapp/widgets/notification_bell_badge.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  bool _isActiveTab = true;

  static const _primaryColor = Color(0xff254356);
  static const _selectedColor = Color(0xff356785);
  static const _unselectedColor = Color(0xffBFBFBF);
  final bg = Color.lerp(Colors.white, _selectedColor, 0.12)!;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: bg,
      appBar: appBar(context),
      bottomNavigationBar: navToolbar(context),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.only(left: 28, right: 20),
            child: JobTabSwitcher(
              initialIsActive: _isActiveTab,
              onChanged: (isActive) => setState(() => _isActiveTab = isActive),
            ),
          ),
          Expanded(child: JobPageWidget(showCompleted: !_isActiveTab)),
        ],
      ),
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

          // Your Jobs (selected)
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _selectedColor,
              shape: BoxShape.circle,
            ),
            child: ImageIcon(
              const AssetImage('assets/icons/your_jobs_icon.png'),
              color: Colors.white,
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
      automaticallyImplyLeading: false,
      backgroundColor: bg,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 20),
          child: NotificationBellBadge(
            iconSize: 40,
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
      toolbarHeight: 100,
      title: Container(
        margin: EdgeInsets.only(left: 20),
        child: Text(
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          'Your Jobs',
        ),
      ),
    );
  }
}
