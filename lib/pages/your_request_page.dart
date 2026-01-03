import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/home_page.dart';
import 'package:serbisyo_mobileapp/models/your_request_model.dart';
import 'package:serbisyo_mobileapp/widgets/your_request_page/tab_switcher_widget.dart';
import 'package:serbisyo_mobileapp/widgets/your_request_page/your_request_card.dart';

class YourRequestPage extends StatefulWidget {
  const YourRequestPage({super.key});

  @override
  State<YourRequestPage> createState() => _YourRequestPageState();
}

class _YourRequestPageState extends State<YourRequestPage> {
  int _selectedTabIndex = 0;

  static const _selectedColor = Color(0xff356785);
  static const _unselectedColor = Color(0xffBFBFBF);

  @override
  Widget build(BuildContext context) {
    final pendingRequests = <YourRequestModel>[
      YourRequestModel(
        status: RequestStatus.pending,
        title: 'Cleaning Service',
        scheduledAt: DateTime(2026, 1, 9, 17, 30),
        iconAssetPath: 'assets/icons/cleaning_icon.png',
      ),
      YourRequestModel(
        status: RequestStatus.pending,
        title: 'Electrical Problem',
        scheduledAt: DateTime(2026, 2, 6, 7, 30),
        iconAssetPath: 'assets/icons/custom_icon.png',
      ),
      YourRequestModel(
        status: RequestStatus.pending,
        title: 'Pet Care',
        scheduledAt: DateTime(2026, 12, 17, 15, 30),
        iconAssetPath: 'assets/icons/pet_icon.png',
      ),
    ];

    final inProgressRequests = <YourRequestModel>[
      YourRequestModel(
        status: RequestStatus.inProgress,
        title: 'Cleaning Service',
        scheduledAt: DateTime(2026, 1, 10, 10, 0),
        iconAssetPath: 'assets/icons/cleaning_icon.png',
        location: 'Purok Pagibig1, Visayan Village',
        provider: RequestProviderModel(
          name: 'Rosalinda Cruz',
          avatarAssetPath: 'assets/icons/Rosalinda.png',
          rating: 4.9,
          reviewCount: 120,
        ),
      ),
      YourRequestModel(
        status: RequestStatus.inProgress,
        title: 'Electrical Problem',
        scheduledAt: DateTime(2026, 2, 7, 9, 30),
        iconAssetPath: 'assets/icons/custom_icon.png',
        location: 'Purok Rafael, Magugpo South',
        provider: RequestProviderModel(
          name: 'Armando Rosales',
          avatarAssetPath: 'assets/icons/Armando.png',
          rating: 4.5,
          reviewCount: 118,
        ),
      ),
      YourRequestModel(
        status: RequestStatus.inProgress,
        title: 'Pet Care',
        scheduledAt: DateTime(2026, 12, 17, 15, 30),
        iconAssetPath: 'assets/icons/pet_icon.png',
        location: 'Purok Rambutan, Visayan Village',
        provider: RequestProviderModel(
          name: 'Corazon Dalisay',
          avatarAssetPath: 'assets/icons/Corazon.png',
          rating: 4.2,
          reviewCount: 98,
        ),
      ),
    ];

    final completedRequests = <YourRequestModel>[
      YourRequestModel(
        status: RequestStatus.completed,
        title: 'Cleaning Service',
        scheduledAt: DateTime(2026, 1, 9, 17, 30),
        iconAssetPath: 'assets/icons/cleaning_icon.png',
        location: 'Purok Pagibig1, Visayan Village',
        provider: RequestProviderModel(
          name: 'Rosalinda Cruz',
          avatarAssetPath: 'assets/icons/Rosalinda.png',
          rating: 4.9,
          reviewCount: 120,
        ),
        duration: '2hrs',
        totalPaid: 'P2,500',
      ),
      YourRequestModel(
        status: RequestStatus.completed,
        title: 'Electrical Problem',
        scheduledAt: DateTime(2026, 2, 6, 7, 30),
        iconAssetPath: 'assets/icons/custom_icon.png',
        location: 'Purok Rafael, Magugpo South',
        provider: RequestProviderModel(
          name: 'Armando Rosales',
          avatarAssetPath: 'assets/icons/Armando.png',
          rating: 4.5,
          reviewCount: 118,
        ),
        duration: '1hr',
        totalPaid: 'P3,000',
      ),
      YourRequestModel(
        status: RequestStatus.completed,
        title: 'Pet Care',
        scheduledAt: DateTime(2025, 12, 17, 15, 30),
        iconAssetPath: 'assets/icons/pet_icon.png',
        location: 'Purok Rambutan, Visayan Village',
        provider: RequestProviderModel(
          name: 'Corazon Dalisay',
          avatarAssetPath: 'assets/icons/Corazon.png',
          rating: 4.2,
          reviewCount: 98,
        ),
        duration: '4hrs',
        totalPaid: 'P6,000',
      ),
    ];

    final requests = switch (_selectedTabIndex) {
      0 => pendingRequests,
      1 => inProgressRequests,
      _ => completedRequests,
    };

    return Scaffold(
      appBar: appBar(),
      bottomNavigationBar: botToolBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabSwitcherWidget(
            initialIndex: _selectedTabIndex,
            onChanged: (index) {
              setState(() => _selectedTabIndex = index);
            },
          ),
          const SizedBox(height: 10),
          sortIcon(),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              reverseDuration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                final currentKey = ValueKey<int>(_selectedTabIndex);
                final isIncoming = child.key == currentKey;

                final position = isIncoming
                    ? Tween<Offset>(
                        begin: const Offset(0.12, 0),
                        end: Offset.zero,
                      ).animate(animation)
                    : Tween<Offset>(
                        begin: Offset.zero,
                        end: const Offset(-0.12, 0),
                      ).animate(animation);

                return SlideTransition(
                  position: position,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: ListView.separated(
                key: ValueKey<int>(_selectedTabIndex),
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return YourRequestCard(
                    request: requests[index],
                    onViewDetails: () {},
                    onCancel: () {},
                    onRateProvider: () {},
                    onBookAgain: () {},
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Align sortIcon() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: ImageIcon(
          const AssetImage('assets/icons/sort_icon.png'),
          size: 24,
        ),
      ),
    );
  }

  Container botToolBar(BuildContext context) {
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
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
                return;
              }

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

          // Tasks (selected)
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _selectedColor,
              shape: BoxShape.circle,
            ),
            child: ImageIcon(
              const AssetImage('assets/icons/request_icon.png'),
              color: Colors.white,
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
    );
  }

  AppBar appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
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
          'Your Requests',
        ),
      ),
    );
  }
}
