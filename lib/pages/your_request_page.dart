import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/home_page.dart';
import 'package:serbisyo_mobileapp/pages/notification_page.dart';
import 'package:serbisyo_mobileapp/pages/profile_page.dart';
import 'package:serbisyo_mobileapp/pages/service_category_page.dart';
import 'package:serbisyo_mobileapp/pages/view_more_details.dart';
import 'package:serbisyo_mobileapp/models/your_request_model.dart';
import 'package:serbisyo_mobileapp/pages/your_request_actions.dart';
import 'package:serbisyo_mobileapp/services/your_requests_service.dart';
import 'package:serbisyo_mobileapp/widgets/your_request_page/tab_switcher_widget.dart';
import 'package:serbisyo_mobileapp/widgets/your_request_page/your_request_card.dart';
import 'package:serbisyo_mobileapp/widgets/notification_bell_badge.dart';

class YourRequestPage extends StatefulWidget {
  const YourRequestPage({super.key});

  @override
  State<YourRequestPage> createState() => _YourRequestPageState();
}

class _YourRequestPageState extends State<YourRequestPage> {
  int _selectedTabIndex = 0;
  final _service = YourRequestsService();
  late final _actions = YourRequestActions(service: _service);

  static const _selectedColor = Color(0xff356785);
  static const _unselectedColor = Color(0xffBFBFBF);
  static const _promptBlue = Color(0xff2B88C1);

  @override
  Widget build(BuildContext context) {
    final uid = _service.currentUserId;

    return Scaffold(
      appBar: appBar(context),
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
          const SizedBox(height: 14),
          Expanded(
            child: uid == null
                ? const SizedBox.shrink()
                : StreamBuilder<List<YourRequestModel>>(
                    stream: _service.watchRequestsForUser(uid),
                    builder: (context, snapshot) {
                      final all = snapshot.data ?? const <YourRequestModel>[];

                      final requests = switch (_selectedTabIndex) {
                        0 =>
                          all
                              .where((r) => r.status == RequestStatus.pending)
                              .toList(growable: false),
                        1 =>
                          all
                              .where(
                                (r) => r.status == RequestStatus.inProgress,
                              )
                              .toList(growable: false),
                        _ =>
                          all
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
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: ListView.separated(
                          key: ValueKey<int>(_selectedTabIndex),
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: requests.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final request = requests[index];

                            void onRateProviderFor(YourRequestModel r) {
                              final providerId = (r.providerId ?? '').trim();
                              if (providerId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Provider not found'),
                                  ),
                                );
                                return;
                              }

                              final providerName =
                                  r.provider?.name ?? 'Provider';

                              _actions.showRateProviderDialog(
                                context: context,
                                requestId: r.id,
                                providerId: providerId,
                                providerName: providerName,
                              );
                            }

                            if (request.provider != null ||
                                request.providerId == null) {
                              return YourRequestCard(
                                request: request,
                                onViewDetails: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ViewMoreDetails(
                                        requestId: request.id,
                                      ),
                                    ),
                                  );
                                },
                                onCancel:
                                    request.status == RequestStatus.pending
                                    ? () => _actions.cancelUserRequest(
                                        context,
                                        requestId: request.id,
                                        promptBlue: _promptBlue,
                                      )
                                    : () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Request is already in progress',
                                            ),
                                          ),
                                        );
                                      },
                                onRateProvider: () =>
                                    onRateProviderFor(request),
                                onBookAgain: () =>
                                    _actions.bookAgain(context, request),
                              );
                            }

                            return FutureBuilder<RequestProviderModel?>(
                              future: _service.fetchProviderById(
                                request.providerId!,
                              ),
                              builder: (context, providerSnap) {
                                final provider = providerSnap.data;
                                final resolved = provider == null
                                    ? request
                                    : request.copyWith(provider: provider);
                                return YourRequestCard(
                                  request: resolved,
                                  onViewDetails: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ViewMoreDetails(
                                          requestId: resolved.id,
                                        ),
                                      ),
                                    );
                                  },
                                  onCancel:
                                      resolved.status == RequestStatus.pending
                                      ? () => _actions.cancelUserRequest(
                                          context,
                                          requestId: resolved.id,
                                          promptBlue: _promptBlue,
                                        )
                                      : () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Request is already in progress',
                                              ),
                                            ),
                                          );
                                        },
                                  onRateProvider: () =>
                                      onRateProviderFor(resolved),
                                  onBookAgain: () =>
                                      _actions.bookAgain(context, resolved),
                                );
                              },
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
          'Your Requests',
        ),
      ),
    );
  }
}
