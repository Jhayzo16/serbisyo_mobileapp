import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/home_page.dart';
import 'package:serbisyo_mobileapp/pages/jobs_page.dart';
import 'package:serbisyo_mobileapp/pages/provider_homepage.dart';
import 'package:serbisyo_mobileapp/pages/profile_page.dart';
import 'package:serbisyo_mobileapp/pages/your_request_page.dart';

class ProfileBottomNavBar extends StatelessWidget {
  const ProfileBottomNavBar({super.key, required this.isProvider});

  final bool isProvider;

  static const _selectedColor = Color(0xff356785);
  static const _unselectedColor = Color(0xffBFBFBF);

  @override
  Widget build(BuildContext context) {
    if (isProvider) {
      return Container(
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: const BoxDecoration(
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
              ),
              child: const ImageIcon(
                AssetImage('assets/icons/profile_icon.png'),
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
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
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            child: ImageIcon(
              const AssetImage('assets/icons/home_icon.png'),
              color: _unselectedColor,
              size: 26,
            ),
          ),
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
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChatPage()),
              );
            },
            child: ImageIcon(
              const AssetImage('assets/icons/message_icon.png'),
              color: _unselectedColor,
              size: 26,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: _selectedColor,
              shape: BoxShape.circle,
            ),
            child: const ImageIcon(
              AssetImage('assets/icons/profile_icon.png'),
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
