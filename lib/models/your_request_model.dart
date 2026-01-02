import 'package:flutter/foundation.dart';

enum RequestStatus { pending, inProgress, completed }

@immutable
class RequestProviderModel {
  final String name;
  final String avatarAssetPath;
  final double rating;
  final int reviewCount;

  const RequestProviderModel({
    required this.name,
    required this.avatarAssetPath,
    required this.rating,
    required this.reviewCount,
  });
}

@immutable
class YourRequestModel {
  final RequestStatus status;
  final String title;
  final DateTime scheduledAt;
  final String iconAssetPath;
  final String? location;
  final RequestProviderModel? provider;
  final String? duration;
  final String? totalPaid;

  const YourRequestModel({
    required this.status,
    required this.title,
    required this.scheduledAt,
    required this.iconAssetPath,
    this.location,
    this.provider,
    this.duration,
    this.totalPaid,
  });
}
