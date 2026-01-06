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
  final String id;
  final RequestStatus status;
  final String title;
  final DateTime scheduledAt;
  final String iconAssetPath;
  final String? location;
  final String? providerId;
  final RequestProviderModel? provider;
  final String? duration;
  final String? totalPaid;

  const YourRequestModel({
    required this.id,
    required this.status,
    required this.title,
    required this.scheduledAt,
    required this.iconAssetPath,
    this.location,
    this.providerId,
    this.provider,
    this.duration,
    this.totalPaid,
  });

  YourRequestModel copyWith({
    String? id,
    RequestStatus? status,
    String? title,
    DateTime? scheduledAt,
    String? iconAssetPath,
    String? location,
    String? providerId,
    RequestProviderModel? provider,
    String? duration,
    String? totalPaid,
  }) {
    return YourRequestModel(
      id: id ?? this.id,
      status: status ?? this.status,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      iconAssetPath: iconAssetPath ?? this.iconAssetPath,
      location: location ?? this.location,
      providerId: providerId ?? this.providerId,
      provider: provider ?? this.provider,
      duration: duration ?? this.duration,
      totalPaid: totalPaid ?? this.totalPaid,
    );
  }
}
