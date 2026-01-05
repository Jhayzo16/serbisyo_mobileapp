import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class JobModel {
  final String requestId;
  final String title;
  final String providerId;
  final String userId;
  final String customerName;
  final String location;
  final DateTime scheduledAt;
  final String iconAssetPath;
  final String status;

  const JobModel({
    required this.requestId,
    required this.title,
    required this.providerId,
    required this.userId,
    required this.customerName,
    required this.location,
    required this.scheduledAt,
    required this.iconAssetPath,
    required this.status,
  });

  static DateTime _scheduledAtFrom(Map<String, dynamic> data) {
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

    final acceptedAt = data['acceptedAt'];
    if (acceptedAt is Timestamp) return acceptedAt.toDate();

    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) return createdAt.toDate();

    return DateTime.now();
  }

  static String _titleFrom(Map<String, dynamic> data) {
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

  static String _iconFrom(Map<String, dynamic> data) {
    final raw = data['iconAssetPath'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return 'assets/icons/custom_icon.png';
  }

  factory JobModel.fromDoc({
    required String requestId,
    required Map<String, dynamic> data,
  }) {
    return JobModel(
      requestId: requestId,
      title: _titleFrom(data),
      providerId: (data['providerId'] ?? '').toString(),
      userId: (data['userId'] ?? '').toString(),
      customerName: (data['customerName'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      scheduledAt: _scheduledAtFrom(data),
      iconAssetPath: _iconFrom(data),
      status: (data['status'] ?? '').toString(),
    );
  }
}
