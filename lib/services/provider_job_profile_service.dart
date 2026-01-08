import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serbisyo_mobileapp/models/provider_job_profile_model.dart';

class ProviderJobProfileService {
  ProviderJobProfileService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static final Map<String, CustomerDisplayInfoModel> _customerCache = {};

  Stream<QuerySnapshot<Map<String, dynamic>>> watchRequestsForProvider(
    String providerId,
  ) {
    return _firestore
        .collection('requests')
        .where('providerId', isEqualTo: providerId)
        .snapshots();
  }

  ProviderJobProfileSummaryModel buildSummary(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    int completedJobs = 0;
    double income = 0.0;

    double ratingSum = 0.0;
    int ratingCount = 0;

    final reviews = <ProviderJobProfileReviewModel>[];

    for (final d in docs) {
      final data = d.data();
      final status = (data['status'] ?? '').toString().trim();
      final isCompleted = status == 'completed';
      final isPaid = data['isPaid'] == true;

      if (isCompleted) {
        completedJobs++;
        if (isPaid) {
          income += _amountFromRequest(data);
        }
      }

      final customerRating = data['customerRating'];
      if (customerRating is num) {
        final rating = customerRating.toDouble();
        ratingSum += rating;
        ratingCount++;

        final customerId = (data['ratedBy'] ?? data['userId'] ?? '')
            .toString()
            .trim();
        final customerName = (data['customerName'] ?? '').toString().trim();
        final comment = (data['reviewComment'] ?? '').toString().trim();

        final ratedAtRaw = data['ratedAt'];
        DateTime? ratedAt;
        if (ratedAtRaw is Timestamp) {
          ratedAt = ratedAtRaw.toDate();
        }

        reviews.add(
          ProviderJobProfileReviewModel(
            customerId: customerId,
            customerNameFallback: customerName,
            rating: rating,
            comment: comment,
            ratedAt: ratedAt,
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
    final ratingLabel = ratingCount == 0
        ? '-'
        : '${avgRating.toStringAsFixed(1)} ($ratingCount)';

    return ProviderJobProfileSummaryModel(
      completedJobs: completedJobs,
      income: income,
      ratingLabel: ratingLabel,
      reviews: reviews,
    );
  }

  Future<CustomerDisplayInfoModel> resolveCustomerInfo({
    required String customerId,
    required String customerNameFallback,
  }) async {
    final trimmedId = customerId.trim();
    if (trimmedId.isNotEmpty) {
      final cached = _customerCache[trimmedId];
      if (cached != null) return cached;
    }

    final snap = trimmedId.isEmpty
        ? null
        : await _firestore.collection('users').doc(trimmedId).get();

    final data = snap?.data() ?? <String, dynamic>{};
    final first = (data['firstName'] ?? '').toString().trim();
    final last = (data['lastName'] ?? '').toString().trim();
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');

    final name = full.isNotEmpty
        ? full
        : (customerNameFallback.trim().isNotEmpty
              ? customerNameFallback.trim()
              : 'Customer');

    final photoUrl = (data['photoUrl'] ?? '').toString().trim();

    final result = CustomerDisplayInfoModel(name: name, photoUrl: photoUrl);
    if (trimmedId.isNotEmpty) {
      _customerCache[trimmedId] = result;
    }
    return result;
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

  String formatPeso(double amount) {
    final safe = amount.isFinite ? amount : 0.0;
    final fixed = safe.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = _formatWithCommas(parts.isNotEmpty ? parts[0] : '0');
    final frac = parts.length > 1 ? parts[1] : '00';
    return '₱$intPart.$frac';
  }

  String _formatWithCommas(String digits) {
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

  double _amountFromRequest(Map<String, dynamic> data) {
    final totalPaid = data['totalPaid'];
    if (totalPaid is num) return totalPaid.toDouble();

    final service = data['service'];
    if (service is Map) {
      final price = service['price'];
      if (price is num) return price.toDouble();
      final priceStr = (price ?? '').toString().trim();
      if (priceStr.isNotEmpty) {
        final parsed = double.tryParse(
          priceStr.replaceAll(RegExp(r'[^0-9.\-]'), ''),
        );
        if (parsed != null) return parsed;
      }
    }

    final budget = (data['budget'] ?? '').toString().trim();
    if (budget.isNotEmpty) {
      final parsed = double.tryParse(
        budget.replaceAll(RegExp(r'[^0-9.\-]'), ''),
      );
      if (parsed != null) return parsed;
    }

    return 0.0;
  }
}
