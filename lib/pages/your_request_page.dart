import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serbisyo_mobileapp/pages/chat_page.dart';
import 'package:serbisyo_mobileapp/pages/home_page.dart';
import 'package:serbisyo_mobileapp/pages/notification_page.dart';
import 'package:serbisyo_mobileapp/pages/profile_page.dart';
import 'package:serbisyo_mobileapp/pages/view_more_details.dart';
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
  static const _promptBlue = Color(0xff2B88C1);

  bool _isCancelledStatus(Object? raw) {
    final v = (raw ?? '').toString().toLowerCase().trim();
    return v == 'cancelled' || v == 'canceled';
  }

  Future<bool> _confirmCancelRequest(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/Penguin_promot_icon.png',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 14),
              const Text(
                'Are you sure you want to cancel this request?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff7C7979),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff254356),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _promptBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  Future<void> _cancelUserRequest(
    BuildContext context, {
    required String requestId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ok = await _confirmCancelRequest(context);
    if (!ok) return;

    final ref = _db.collection('requests').doc(requestId);
    try {
      await ref.delete();
    } on FirebaseException {
      // Fallback if delete is not allowed by Firestore rules.
      await ref.set({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': uid,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _showRateProviderDialog({
    required BuildContext context,
    required String requestId,
    required String providerId,
    required String providerName,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final commentController = TextEditingController();

    var selectedRating = 0;
    var isSubmitting = false;

    Future<void> submit(StateSetter setState) async {
      if (selectedRating <= 0 || isSubmitting) return;
      setState(() => isSubmitting = true);

      try {
        final requestRef = _db.collection('requests').doc(requestId);

        // Read first to prevent double-rating.
        final requestSnap = await requestRef.get();
        final requestData = requestSnap.data() ?? <String, dynamic>{};
        if (requestData['customerRating'] is num) {
          throw StateError('already-rated');
        }

        final rating = selectedRating.toDouble();
        final comment = commentController.text.trim();

        // Always save the customer's review to the request doc.
        // This is the most reliable place because request rules usually allow the owning customer.
        await requestRef.set({
          'customerRating': rating,
          'reviewComment': comment,
          'ratedAt': FieldValue.serverTimestamp(),
          'ratedBy': uid,
        }, SetOptions(merge: true));

        // Best-effort provider aggregate update (can fail due to Firestore rules).
        try {
          final providerRef = _db.collection('providers').doc(providerId);
          final providerSnap = await providerRef.get();
          if (providerSnap.exists) {
            final providerData = providerSnap.data() ?? <String, dynamic>{};
            final currentRating =
                (providerData['rating'] as num?)?.toDouble() ?? 0.0;
            final currentCount =
                (providerData['reviewCount'] as num?)?.toInt() ??
                (providerData['reviews'] as num?)?.toInt() ??
                0;
            final nextCount = currentCount + 1;
            final nextRating =
                ((currentRating * currentCount) + rating) / nextCount;
            await providerRef.set({
              'rating': nextRating,
              'reviewCount': nextCount,
            }, SetOptions(merge: true));
          }
        } catch (_) {
          // Ignore: customer might not have permission to update provider aggregates.
        }

        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks! Your review was submitted.')),
        );
      } on StateError catch (e) {
        if (!context.mounted) return;
        if (e.message == 'already-rated') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You already rated this provider.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit review')),
          );
        }
      } on FirebaseException catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: ${e.code}')),
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review')),
        );
      } finally {
        if (context.mounted) {
          setState(() => isSubmitting = false);
        }
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            Widget star(int index) {
              final filled = selectedRating >= index;
              return IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                onPressed: isSubmitting
                    ? null
                    : () => setState(() => selectedRating = index),
                icon: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: const Color(0xffF2C94C),
                ),
              );
            }

            return AlertDialog(
              title: Text('Rate $providerName'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [star(1), star(2), star(3), star(4), star(5)],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Comment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: commentController,
                      enabled: !isSubmitting,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Add a short comment…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (selectedRating > 0 && !isSubmitting)
                      ? () => submit(setState)
                      : null,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  RequestStatus _parseStatus(Object? raw) {
    final v = (raw ?? 'pending').toString().toLowerCase();
    if (v == 'inprogress' || v == 'in_progress')
      return RequestStatus.inProgress;
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

  RequestProviderModel? _providerFromEmbedded(Object? raw) {
    if (raw is! Map) return null;
    final map = raw.cast<String, dynamic>();

    String name;
    final firstName = (map['firstName'] ?? '').toString();
    final lastName = (map['lastName'] ?? '').toString();
    final combined = [
      firstName.trim(),
      lastName.trim(),
    ].where((s) => s.isNotEmpty).join(' ');
    name = combined.isNotEmpty ? combined : (map['name'] ?? '').toString();
    if (name.trim().isEmpty) name = 'Provider';

    final photoUrl = (map['photoUrl'] ?? map['avatarUrl'] ?? '')
        .toString()
        .trim();
    final avatar = photoUrl.isNotEmpty
        ? photoUrl
        : 'assets/icons/profile_icon.png';

    final rating = (map['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount =
        (map['reviewCount'] as num?)?.toInt() ??
        (map['reviews'] as num?)?.toInt() ??
        0;

    return RequestProviderModel(
      name: name,
      avatarAssetPath: avatar,
      rating: rating,
      reviewCount: reviewCount,
    );
  }

  Future<RequestProviderModel?> _fetchProviderById(String providerId) async {
    final id = providerId.trim();
    if (id.isEmpty) return null;

    final snap = await _db.collection('providers').doc(id).get();
    final data = snap.data();
    if (!snap.exists || data == null) return null;

    final firstName = (data['firstName'] ?? '').toString();
    final lastName = (data['lastName'] ?? '').toString();
    final combined = [
      firstName.trim(),
      lastName.trim(),
    ].where((s) => s.isNotEmpty).join(' ');
    final name = combined.isNotEmpty ? combined : 'Provider';

    final photoUrl = (data['photoUrl'] ?? '').toString().trim();
    final avatar = photoUrl.isNotEmpty
        ? photoUrl
        : 'assets/icons/profile_icon.png';

    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount =
        (data['reviewCount'] as num?)?.toInt() ??
        (data['reviews'] as num?)?.toInt() ??
        0;

    return RequestProviderModel(
      name: name,
      avatarAssetPath: avatar,
      rating: rating,
      reviewCount: reviewCount,
    );
  }

  YourRequestModel _toRequestModel({
    required String requestId,
    required Map<String, dynamic> data,
  }) {
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
    final location = data['location'] is String
        ? data['location'] as String
        : null;

    final providerId = data['providerId'] is String
        ? data['providerId'] as String
        : null;
    final provider = _providerFromEmbedded(data['provider']);

    return YourRequestModel(
      id: requestId,
      status: status,
      title: title,
      scheduledAt: scheduledAt,
      iconAssetPath: iconAssetPath ?? _iconForRequest(type: type, title: title),
      location: location,
      providerId: providerId,
      provider: provider,
      duration: null,
      totalPaid: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

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
                          .where((d) => !_isCancelledStatus(d.data()['status']))
                          .map(
                            (d) => _toRequestModel(
                              requestId: d.id,
                              data: d.data(),
                            ),
                          )
                          .toList(growable: false);

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

                              _showRateProviderDialog(
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
                                    ? () => _cancelUserRequest(
                                        context,
                                        requestId: request.id,
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
                                onBookAgain: () {},
                              );
                            }

                            return FutureBuilder<RequestProviderModel?>(
                              future: _fetchProviderById(request.providerId!),
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
                                      ? () => _cancelUserRequest(
                                          context,
                                          requestId: resolved.id,
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
                                  onBookAgain: () {},
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
                  builder: (_) => const NotificationPage(isProvider: false),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          'Your Requests',
        ),
      ),
    );
  }
}
