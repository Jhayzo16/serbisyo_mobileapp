import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serbisyo_mobileapp/pages/provider_public_profile_page.dart';
import 'package:serbisyo_mobileapp/widgets/app_elevated_card.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewDetailsWidget extends StatelessWidget {
  const ViewDetailsWidget({
    super.key,
    required this.requestId,
    this.isProviderView = false,
  });

  final String requestId;
  final bool isProviderView;

  static const _primaryColor = Color(0xff254356);
  static const _mutedText = Color(0xff7C7979);
  static const _borderColor = Color(0xffD1D5DB);
  static const _actionBlue = Color(0xff2B88C1);

  Future<void> _setPaidStatus(
    BuildContext context, {
    required bool isPaid,
  }) async {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null) return;

    try {
      final update = <String, Object?>{'isPaid': isPaid};

      if (isPaid) {
        update['paidAt'] = FieldValue.serverTimestamp();
        update['paidMarkedBy'] = me;
      } else {
        update['paidAt'] = FieldValue.delete();
        update['paidMarkedBy'] = FieldValue.delete();
      }

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .set(update, SetOptions(merge: true));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update payment status')),
      );
    }
  }

  Future<void> _completeJob(
    BuildContext context, {
    required bool isPaid,
  }) async {
    if (!isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mark customer as paid to complete the job'),
        ),
      );
      return;
    }

    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null) return;

    try {
      final db = FirebaseFirestore.instance;
      final reqRef = db.collection('requests').doc(requestId);
      final notifRef = db.collection('notifications').doc();

      await db.runTransaction((tx) async {
        final snap = await tx.get(reqRef);
        final data = snap.data() as Map<String, dynamic>?;
        final userId = (data?['userId'] ?? '').toString().trim();

        tx.set(reqRef, {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'completedBy': me,
        }, SetOptions(merge: true));

        if (userId.isEmpty) return;

        String serviceName = '';
        final service = data?['service'];
        if (service is Map) {
          serviceName = (service['name'] ?? '').toString().trim();
        }
        if (serviceName.isEmpty) {
          serviceName = (data?['title'] ?? data?['type'] ?? '')
              .toString()
              .trim();
        }

        final body = serviceName.isNotEmpty
            ? 'Your request for $serviceName has been completed!'
            : 'Your request has been completed!';

        tx.set(notifRef, {
          'recipientId': userId,
          'senderId': me,
          'type': 'jobCompleted',
          'title': 'Serbisyo',
          'body': body,
          'requestId': requestId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
          'createdAtClient': Timestamp.now(),
        });
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job marked as completed')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to complete job')));
    }
  }

  Widget _paymentSection(BuildContext context, {required bool isPaid}) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Payment'),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Payment Received',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _mutedText,
                  ),
                ),
              ),
              Switch.adaptive(
                value: isPaid,
                onChanged: (v) => _setPaidStatus(context, isPaid: v),
                activeColor: _actionBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, $hour12:$minute $ampm';
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

  String _titleFrom(Map<String, dynamic> data) {
    final type = (data['type'] ?? 'service').toString();
    if (type == 'custom') {
      return (data['title'] ?? 'Custom Request').toString();
    }

    final service = data['service'];
    if (service is Map) {
      return (service['name'] ?? 'Service Request').toString();
    }
    return 'Service Request';
  }

  List<String> _imageUrlsFrom(Map<String, dynamic> data) {
    final fromImageUrls = data['imageUrls'];
    if (fromImageUrls is List) {
      return fromImageUrls
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    // Custom requests in older code might keep images under 'images'
    final fromImages = data['images'];
    if (fromImages is List) {
      return fromImages
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    return const [];
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _mutedText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return AppElevatedCard(
      elevation: 6,
      borderRadius: 12,
      borderSide: const BorderSide(color: _borderColor, width: 1),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: child,
    );
  }

  Future<void> _openMaps(
    BuildContext context, {
    required String location,
  }) async {
    final query = location.trim();
    if (query.isEmpty) return;

    String destination = query;
    final latLng = _tryParseLatLng(query);
    if (latLng != null) {
      destination = '${latLng.$1},${latLng.$2}';
    }

    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destination,
      'travelmode': 'driving',
    });

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unable to open maps')));
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open maps')));
    }
  }

  (double, double)? _tryParseLatLng(String text) {
    // Accept formats like: "14.599512, 120.984222" (optionally with extra text).
    final match = RegExp(
      r'(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)',
    ).firstMatch(text);
    if (match == null) return null;

    final lat = double.tryParse(match.group(1) ?? '');
    final lng = double.tryParse(match.group(2) ?? '');
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  Widget _mapsButton(BuildContext context, {required String location}) {
    return SizedBox(
      height: 34,
      child: OutlinedButton(
        onPressed: () => _openMaps(context, location: location),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Navigate',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _customerProfileSection({required String userId}) {
    if (userId.trim().isEmpty) {
      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Customer'),
            _infoRow(icon: Icons.person_outline, text: 'Customer'),
          ],
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        final data = snap.data?.data() ?? <String, dynamic>{};
        final first = (data['firstName'] ?? '').toString().trim();
        final last = (data['lastName'] ?? '').toString().trim();
        final name = [first, last].where((s) => s.isNotEmpty).join(' ');
        final email = (data['email'] ?? '').toString().trim();
        final phone = (data['phone'] ?? '').toString().trim();
        final location = (data['location'] ?? '').toString().trim();
        final photoUrl = (data['photoUrl'] ?? '').toString().trim();

        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Customer'),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: const AssetImage(
                      'assets/icons/profile_icon.png',
                    ),
                    foregroundImage: photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name.isNotEmpty ? name : 'Customer',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (phone.isNotEmpty)
                _infoRow(icon: Icons.phone_outlined, text: phone),
              if (email.isNotEmpty)
                _infoRow(icon: Icons.email_outlined, text: email),
              if (location.isNotEmpty)
                _infoRow(icon: Icons.location_on_outlined, text: location),
            ],
          ),
        );
      },
    );
  }

  Widget _providerProfileSection({required String providerId}) {
    if (providerId.trim().isEmpty) {
      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Provider'),
            _infoRow(icon: Icons.person_outline, text: 'No provider yet'),
          ],
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('providers')
        .doc(providerId)
        .snapshots();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        final data = snap.data?.data() ?? <String, dynamic>{};
        final first = (data['firstName'] ?? '').toString().trim();
        final last = (data['lastName'] ?? '').toString().trim();
        final name = [first, last].where((s) => s.isNotEmpty).join(' ');
        final email = (data['email'] ?? '').toString().trim();
        final phone = (data['phone'] ?? '').toString().trim();
        final location = (data['location'] ?? '').toString().trim();
        final photoUrl = (data['photoUrl'] ?? '').toString().trim();
        final safeProviderId = providerId.trim();

        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Provider'),
              InkWell(
                onTap: safeProviderId.isEmpty
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProviderPublicProfilePage(
                              providerId: safeProviderId,
                            ),
                          ),
                        );
                      },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: const AssetImage(
                          'assets/icons/profile_icon.png',
                        ),
                        foregroundImage: photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        backgroundColor: Colors.grey.shade200,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name.isNotEmpty ? name : 'Provider',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (phone.isNotEmpty)
                _infoRow(icon: Icons.phone_outlined, text: phone),
              if (email.isNotEmpty)
                _infoRow(icon: Icons.email_outlined, text: email),
              if (location.isNotEmpty)
                _infoRow(icon: Icons.location_on_outlined, text: location),
            ],
          ),
        );
      },
    );
  }

  Widget _requestDetailsSection(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) {
    final title = _titleFrom(data).trim();
    final status = (data['status'] ?? '').toString().trim();
    final location = (data['location'] ?? '').toString().trim();
    final scheduledAt = _scheduledAtFrom(data);
    final type = (data['type'] ?? 'service').toString().trim();

    final notes = (data['notes'] ?? '').toString().trim();
    final description = (data['description'] ?? '').toString().trim();
    final budget = (data['budget'] ?? '').toString().trim();

    final service = data['service'];
    final serviceDesc = (service is Map)
        ? (service['description'] ?? '').toString().trim()
        : '';
    final servicePrice = (service is Map)
        ? (service['price'] ?? '').toString().trim()
        : '';
    final serviceDuration = (service is Map)
        ? (service['duration'] ?? '').toString().trim()
        : '';

    final iconAssetPath =
        (data['iconAssetPath'] ?? 'assets/icons/custom_icon.png').toString();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Request'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImageIcon(AssetImage(iconAssetPath), size: 22, color: _mutedText),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title.isNotEmpty ? title : 'Request',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (status.isNotEmpty)
            _infoRow(icon: Icons.info_outline, text: 'Status: $status'),
          _infoRow(
            icon: Icons.calendar_month_outlined,
            text: _formatDateTime(scheduledAt),
          ),
          if (location.isNotEmpty)
            _infoRow(icon: Icons.location_on_outlined, text: location),
          if (status == 'inProgress' && location.isNotEmpty) ...[
            const SizedBox(height: 2),
            _mapsButton(context, location: location),
            const SizedBox(height: 10),
          ],
          if (type == 'custom' && description.isNotEmpty)
            _infoRow(icon: Icons.description_outlined, text: description),
          if (type == 'service' && notes.isNotEmpty)
            _infoRow(icon: Icons.notes_outlined, text: notes),
          if (type == 'custom' && budget.isNotEmpty)
            _infoRow(icon: Icons.payments_outlined, text: 'Budget: $budget'),
          if (type == 'service' && serviceDuration.isNotEmpty)
            _infoRow(
              icon: Icons.access_time_outlined,
              text: 'Duration: $serviceDuration',
            ),
          if (type == 'service' && servicePrice.isNotEmpty)
            _infoRow(
              icon: Icons.payments_outlined,
              text: 'Price: $servicePrice',
            ),
          if (type == 'service' && serviceDesc.isNotEmpty)
            _infoRow(icon: Icons.description_outlined, text: serviceDesc),
        ],
      ),
    );
  }

  Widget _imagesSection(List<String> urls) {
    if (urls.isEmpty) return const SizedBox.shrink();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Photos'),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: urls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final url = urls[index].trim();
                if (url.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _FullScreenImagePage(imageUrl: url),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: _mutedText,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (requestId.trim().isEmpty) {
      return const Center(
        child: Text('Request not found.', style: TextStyle(color: _mutedText)),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Failed to load details.',
              style: TextStyle(color: _mutedText),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data();
        if (data == null) {
          return const Center(
            child: Text(
              'Request not found.',
              style: TextStyle(color: _mutedText),
            ),
          );
        }

        final userId = (data['userId'] ?? '').toString();
        final providerId = (data['providerId'] ?? '').toString();
        final urls = _imageUrlsFrom(data);
        final status = (data['status'] ?? '').toString().trim();
        final providerIdTrimmed = providerId.trim();
        final me = FirebaseAuth.instance.currentUser?.uid;
        final isProviderViewer =
            me != null &&
            providerIdTrimmed.isNotEmpty &&
            me == providerIdTrimmed;
        final showCustomerSection = isProviderView || isProviderViewer;
        final canComplete = status == 'inProgress' && isProviderViewer;
        final isPaid = data['isPaid'] == true;
        final canCompleteJob = canComplete && isPaid;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              showCustomerSection
                  ? _customerProfileSection(userId: userId)
                  : _providerProfileSection(providerId: providerIdTrimmed),
              const SizedBox(height: 14),
              _requestDetailsSection(context, data: data),
              if (canComplete) ...[
                const SizedBox(height: 14),
                _paymentSection(context, isPaid: isPaid),
                const SizedBox(height: 14),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: canCompleteJob
                        ? () => _completeJob(context, isPaid: isPaid)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _actionBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Complete Job',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
              if (urls.isNotEmpty) ...[
                const SizedBox(height: 14),
                _imagesSection(urls),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FullScreenImagePage extends StatelessWidget {
  const _FullScreenImagePage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: url.isEmpty
            ? const Icon(Icons.broken_image_outlined, color: Colors.white70)
            : InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white70,
                    );
                  },
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
