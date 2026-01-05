import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/home_page.dart';
import 'package:serbisyo_mobileapp/pages/profile_page.dart';
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

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const _selectedColor = Color(0xff356785);
  static const _unselectedColor = Color(0xffBFBFBF);

  RequestStatus _parseStatus(Object? raw) {
    final v = (raw ?? 'pending').toString().toLowerCase();
    if (v == 'inprogress' || v == 'in_progress') return RequestStatus.inProgress;
    if (v == 'completed' || v == 'done') return RequestStatus.completed;
    return RequestStatus.pending;
  }

  String _iconForRequest({required String type, required String? title}) {
    if (type == 'custom') return 'assets/icons/custom_icon.png';
    final t = (title ?? '').toLowerCase();
    if (t.contains('window')) return 'assets/icons/window_cleaning_icon.png';
    if (t.contains('clean')) return 'assets/icons/cleaning_icon.png';
    if (t.contains('pet')) return 'assets/icons/pet_icon.png';
    return 'assets/icons/custom_icon.png';
  }

  DateTime _scheduledAtFrom(Map<String, dynamic> data) {
    final dateRaw = data['date'];
    final timeRaw = data['time'];

    DateTime? date;
    if (dateRaw is String && dateRaw.isNotEmpty) {
      date = DateTime.tryParse(dateRaw);
    }

    int hour = 0;
    int minute = 0;
    if (timeRaw is String && timeRaw.isNotEmpty) {
      final parts = timeRaw.split(':');
      if (parts.isNotEmpty) hour = int.tryParse(parts[0]) ?? 0;
      if (parts.length > 1) minute = int.tryParse(parts[1]) ?? 0;
    }

    if (date != null) {
      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) return createdAt.toDate();
    return DateTime.now();
  }

  YourRequestModel _toRequestModel(Map<String, dynamic> data) {
    final type = (data['type'] ?? 'service').toString();

    final iconFromDb = data['iconAssetPath'];
    final iconAssetPath = (iconFromDb is String && iconFromDb.trim().isNotEmpty)
        ? iconFromDb.trim()
        : null;

    String title;
    if (type == 'service') {
      final service = data['service'];
      if (service is Map) {
        title = (service['name'] ?? 'Service Request').toString();
      } else {
        title = 'Service Request';
      }
    } else {
      title = (data['title'] ?? 'Custom Request').toString();
    }

    final status = _parseStatus(data['status']);
    final scheduledAt = _scheduledAtFrom(data);
    final location = data['location'] is String ? data['location'] as String : null;

    return YourRequestModel(
      status: status,
      title: title,
      scheduledAt: scheduledAt,
      iconAssetPath: iconAssetPath ?? _iconForRequest(type: type, title: title),
      location: location,
      provider: null,
      duration: null,
      totalPaid: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

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
            child: uid == null
                ? const SizedBox.shrink()
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _db
                        .collection('requests')
                        .where('userId', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? const [];
                      final all = docs
                          .map((d) => _toRequestModel(d.data()))
                          .toList(growable: false);

                      final requests = switch (_selectedTabIndex) {
                        0 => all
                            .where((r) => r.status == RequestStatus.pending)
                            .toList(growable: false),
                        1 => all
                            .where((r) => r.status == RequestStatus.inProgress)
                            .toList(growable: false),
                        _ => all
                            .where((r) => r.status == RequestStatus.completed)
                            .toList(growable: false),
                      };

                      if (requests.isEmpty) {
                        return const Center(
                          child: Text(
                            'No requests yet',
                            style: TextStyle(color: Color(0xff7C7979)),
                          ),
                        );
                      }

                      return AnimatedSwitcher(
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
                      );
                    },
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
