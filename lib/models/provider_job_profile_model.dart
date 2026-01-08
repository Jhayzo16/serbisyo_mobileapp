class ProviderJobProfileReviewModel {
  final String customerId;
  final String customerNameFallback;
  final double rating;
  final String comment;
  final DateTime? ratedAt;

  const ProviderJobProfileReviewModel({
    required this.customerId,
    required this.customerNameFallback,
    required this.rating,
    required this.comment,
    required this.ratedAt,
  });
}

class ProviderJobProfileSummaryModel {
  final int completedJobs;
  final double income;
  final String ratingLabel;
  final List<ProviderJobProfileReviewModel> reviews;

  const ProviderJobProfileSummaryModel({
    required this.completedJobs,
    required this.income,
    required this.ratingLabel,
    required this.reviews,
  });
}

class CustomerDisplayInfoModel {
  final String name;
  final String photoUrl;

  const CustomerDisplayInfoModel({required this.name, required this.photoUrl});
}
