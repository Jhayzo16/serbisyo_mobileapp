import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/notification_page.dart';
import 'package:serbisyo_mobileapp/pages/profile_page.dart';
import 'package:serbisyo_mobileapp/pages/your_request_page.dart';
import 'package:serbisyo_mobileapp/pages/service_category_page.dart';
import 'package:serbisyo_mobileapp/widgets/notification_bell_badge.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/home_widget.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/home_widget_category.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/home_widget_search.dart';
import 'package:serbisyo_mobileapp/services/home_category_service.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/home_category_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const _selectedColor = Color(0xff356785);
  static const _unselectedColor = Color(0xffBFBFBF);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _categoryService = const HomeCategoryService();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _categoryService.filterByLabel(_query);

    return Scaffold(
      appBar: appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeWidget(),
              HomeWidgetSearch(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
              if (_query.trim().isEmpty)
                HomeWidgetCategory()
              else
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: results.isEmpty
                      ? Padding(
                          padding: EdgeInsets.only(left: 20, right: 20, top: 8),
                          child: Text(
                            'No categories found',
                            style: TextStyle(
                              color: Color(0xff9B9B9B),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                          children: results.map((c) {
                            return HomeCategoryCard(
                              label: c.label,
                              iconAsset: c.iconAsset,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ServiceCategoryPage(
                                      title: c.title,
                                      services: c.services,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                ),
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
                color: HomePage._selectedColor,
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
                color: HomePage._unselectedColor,
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
                color: HomePage._unselectedColor,
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
                color: HomePage._unselectedColor,
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
      automaticallyImplyLeading: false,
      actions: [
        Container(
          margin: EdgeInsets.only(top: 50, right: 20),
          child: NotificationBellBadge(
            iconSize: 40,
            iconColor: Colors.black,
            onPressed: () {
             
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
