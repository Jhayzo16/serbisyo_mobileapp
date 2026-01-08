import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:serbisyo_mobileapp/models/provider_public_profile_model.dart';

class ProviderPublicProfileService {
  ProviderPublicProfileService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  final Map<String, Future<ProviderPublicProfileReviewerInfo>> _reviewerCache =
      <String, Future<ProviderPublicProfileReviewerInfo>>{};

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProvider({
    required String providerId,
  }) {
    return _db.collection('providers').doc(providerId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchProviderRequests({
    required String providerId,
  }) {
    return _db
        .collection('requests')
        .where('providerId', isEqualTo: providerId)
        .snapshots();
  }

  ProviderPublicProfileSummary summaryFromProviderData(
    Map<String, dynamic> provider,
  ) {
    final first = (provider['firstName'] ?? '').toString().trim();
    final last = (provider['lastName'] ?? '').toString().trim();
    final name = [first, last].where((s) => s.isNotEmpty).join(' ').trim();
    final jobTitle = (provider['jobTitle'] ?? '').toString().trim();
    final photoUrl = (provider['photoUrl'] ?? '').toString().trim();

    return ProviderPublicProfileSummary(
      name: name,
      jobTitle: jobTitle,
      photoUrl: photoUrl,
    );
  }

  ProviderPublicProfileStats statsFromRequests(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    int finished = 0;
    double ratingSum = 0.0;
    int ratingCount = 0;

    final reviews = <ProviderPublicProfileReview>[];

    for (final d in docs) {
      final data = d.data();
      final status = (data['status'] ?? '').toString().trim();
      if (status == 'completed') finished++;

      final customerRating = data['customerRating'];
      if (customerRating is num) {
        final rating = customerRating.toDouble();
        ratingSum += rating;
        ratingCount++;

        final comment = (data['reviewComment'] ?? '').toString().trim();
        final customerId = (data['ratedBy'] ?? data['userId'] ?? '')
            .toString()
            .trim();
        final customerName = (data['customerName'] ?? '').toString().trim();
        final ratedAtRaw = data['ratedAt'];
        DateTime? ratedAt;
        if (ratedAtRaw is Timestamp) {
          ratedAt = ratedAtRaw.toDate();
        }

        reviews.add(
          ProviderPublicProfileReview(
            rating: rating,
            comment: comment,
            ratedAt: ratedAt,
            customerId: customerId,
            customerName: customerName,
          ),
        );
      }
    }

    reviews.sort((a, b) {
      final at = a.ratedAt;
      final bt = b.ratedAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });

    final avgRating = ratingCount == 0 ? 0.0 : (ratingSum / ratingCount);

    return ProviderPublicProfileStats(
      finishedJobs: finished,
      avgRating: avgRating,
      reviewCount: ratingCount,
      reviews: reviews,
    );
  }

  String formatWithCommas(String digits) {
    final raw = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return '0';
    final buf = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final fromEnd = raw.length - i;
      buf.write(raw[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  String formatShortDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[(dt.month - 1).clamp(0, 11)];
    return '$m ${dt.day}, ${dt.year}';
  }

  Future<ProviderPublicProfileReviewerInfo> loadReviewerInfo({
    required String customerId,
  }) {
    final safe = customerId.trim();
    if (safe.isEmpty) {
      return Future.value(
        const ProviderPublicProfileReviewerInfo(name: '', photoUrl: ''),
      );
    }

    return _reviewerCache.putIfAbsent(safe, () async {
      try {
        final snap = await _db.collection('users').doc(safe).get();
        final data = snap.data() ?? <String, dynamic>{};
        final first = (data['firstName'] ?? '').toString().trim();
        final last = (data['lastName'] ?? '').toString().trim();
        final fullName = [first, last].where((s) => s.isNotEmpty).join(' ');
        final photoUrl = (data['photoUrl'] ?? '').toString().trim();
        return ProviderPublicProfileReviewerInfo(
          name: fullName.trim(),
          photoUrl: photoUrl,
        );
      } catch (_) {
        return const ProviderPublicProfileReviewerInfo(name: '', photoUrl: '');
      }
    });
  }
}
