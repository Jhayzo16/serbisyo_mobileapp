class ProviderPublicProfileSummary {
  const ProviderPublicProfileSummary({
    required this.name,
    required this.jobTitle,
    required this.photoUrl,
  });

  final String name;
  final String jobTitle;
  final String photoUrl;
}

class ProviderPublicProfileReview {
  const ProviderPublicProfileReview({
    required this.rating,
    required this.comment,
    required this.ratedAt,
    required this.customerId,
    required this.customerName,
  });

  final double rating;
  final String comment;
  final DateTime? ratedAt;
  final String customerId;
  final String customerName;
}

class ProviderPublicProfileStats {
  const ProviderPublicProfileStats({
    required this.finishedJobs,
    required this.avgRating,
    required this.reviewCount,
    required this.reviews,
  });

  final int finishedJobs;
  final double avgRating;
  final int reviewCount;
  final List<ProviderPublicProfileReview> reviews;
}

class ProviderPublicProfileViewModel {
  const ProviderPublicProfileViewModel({
    required this.summary,
    required this.stats,
  });

  final ProviderPublicProfileSummary summary;
  final ProviderPublicProfileStats stats;
}

class ProviderPublicProfileReviewerInfo {
  const ProviderPublicProfileReviewerInfo({
    required this.name,
    required this.photoUrl,
  });

  final String name;
  final String photoUrl;
}
