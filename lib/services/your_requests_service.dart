import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';
import 'package:serbisyo_mobileapp/models/your_request_model.dart';
import 'package:serbisyo_mobileapp/services/home_category_service.dart';

class YourRequestsService {
  YourRequestsService({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
    HomeCategoryService? categoryService,
  }) : _db = db ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _categoryService = categoryService ?? const HomeCategoryService();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final HomeCategoryService _categoryService;

  String? get currentUserId => _auth.currentUser?.uid;

  bool isCancelledStatus(Object? raw) {
    final v = (raw ?? '').toString().toLowerCase().trim();
    return v == 'cancelled' || v == 'canceled';
  }

  RequestStatus parseStatus(Object? raw) {
    final v = (raw ?? 'pending').toString().toLowerCase();
    if (v == 'inprogress' || v == 'in_progress') {
      return RequestStatus.inProgress;
    }
    if (v == 'completed' || v == 'done') return RequestStatus.completed;
    return RequestStatus.pending;
  }

  String iconForRequest({required String type, required String? title}) {
    if (type == 'custom') return 'assets/icons/custom_icon.png';

    final t = (title ?? '').toLowerCase();
    if (t.contains('window')) return 'assets/icons/window_cleaning_icon.png';
    if (t.contains('deep')) return 'assets/icons/deep_cleaning_icon.png';
    if (t.contains('clean')) return 'assets/icons/cleaning_icon.png';

    if (t.contains('leak')) return 'assets/icons/leak_repair_icon.png';
    if (t.contains('toilet')) return 'assets/icons/toilet_repair_icon.png';
    if (t.contains('pipe')) return 'assets/icons/pipe_installation_icon.png';
    if (t.contains('plumb')) return 'assets/icons/plumbing_icon.png';

    if (t.contains('grocery')) return 'assets/icons/grocery_icon.png';
    if (t.contains('market'))
      return 'assets/icons/publicmarket_errand_icon.png';
    if (t.contains('bill')) return 'assets/icons/billpayment_icon.png';
    if (t.contains('errand')) return 'assets/icons/errand_icon.png';

    if (t.contains('pet')) return 'assets/icons/pet_icon.png';

    if (t.contains('haircut') || t.contains('nail') || t.contains('massage')) {
      return 'assets/icons/Beauty.png';
    }

    if (t.contains('aircon') ||
        (t.contains('air') && t.contains('conditioning'))) {
      return 'assets/icons/Aircon.png';
    }

    if (t.contains('motorcycle') ||
        t.contains('vulcan') ||
        t.contains('tire')) {
      return 'assets/icons/carr_repair.png';
    }
    if (t.contains('car') && (t.contains('wash') || t.contains('repair'))) {
      return 'assets/icons/carr_repair.png';
    }

    if (t.contains('delivery') || t.contains('package')) {
      return 'assets/icons/car_icon.png';
    }

    if (t.contains('carpentry') ||
        t.contains('masonry') ||
        t.contains('painting') ||
        t.contains('roof') ||
        t.contains('welding')) {
      return 'assets/icons/Construction.png';
    }

    return 'assets/icons/custom_icon.png';
  }

  DateTime scheduledAtFrom(Map<String, dynamic> data) {
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

  RequestProviderModel? providerFromEmbedded(Object? raw) {
    if (raw is! Map) return null;
    final map = raw.cast<String, dynamic>();

    final firstName = (map['firstName'] ?? '').toString();
    final lastName = (map['lastName'] ?? '').toString();
    final combined = [
      firstName.trim(),
      lastName.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    var name = combined.isNotEmpty ? combined : (map['name'] ?? '').toString();
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

  Future<RequestProviderModel?> fetchProviderById(String providerId) async {
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

  YourRequestModel toRequestModel({
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

    final status = parseStatus(data['status']);
    final scheduledAt = scheduledAtFrom(data);

    final location = data['location'] is String
        ? data['location'] as String
        : null;

    final providerId = data['providerId'] is String
        ? data['providerId'] as String
        : null;
    final provider = providerFromEmbedded(data['provider']);

    return YourRequestModel(
      id: requestId,
      status: status,
      title: title,
      scheduledAt: scheduledAt,
      iconAssetPath: iconAssetPath ?? iconForRequest(type: type, title: title),
      location: location,
      providerId: providerId,
      provider: provider,
      duration: null,
      totalPaid: null,
    );
  }

  Stream<List<YourRequestModel>> watchRequestsForUser(String userId) {
    return _db
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((d) => !isCancelledStatus(d.data()['status']))
              .map((d) => toRequestModel(requestId: d.id, data: d.data()))
              .toList(growable: false);
        });
  }

  Future<void> cancelRequest({required String requestId}) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Not authenticated');

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

  Future<void> submitProviderRating({
    required String requestId,
    required String providerId,
    required double rating,
    required String comment,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Not authenticated');

    final requestRef = _db.collection('requests').doc(requestId);

    // Read first to prevent double-rating.
    final requestSnap = await requestRef.get();
    final requestData = requestSnap.data() ?? <String, dynamic>{};
    if (requestData['customerRating'] is num) {
      throw StateError('already-rated');
    }

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
  }

  ({String title, List<ServiceItemModel> services, int selectedIndex})?
  findServiceForBookAgain(String requestTitle) {
    String normalize(String s) => s.toLowerCase().trim();

    final target = normalize(requestTitle);
    if (target.isEmpty) return null;

    final categories = _categoryService.allCategories();

    for (final c in categories) {
      for (int i = 0; i < c.services.length; i++) {
        final name = normalize(c.services[i].name);
        if (name == target) {
          return (title: c.title, services: c.services, selectedIndex: i);
        }
      }
    }

    for (final c in categories) {
      for (int i = 0; i < c.services.length; i++) {
        final name = normalize(c.services[i].name);
        if (name.contains(target) || target.contains(name)) {
          return (title: c.title, services: c.services, selectedIndex: i);
        }
      }
    }

    return null;
  }
}
