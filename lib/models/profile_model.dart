import 'package:flutter/foundation.dart';

@immutable
class ProfileModel {
  final String uid;
  final String role;
  final String email;
  final String photoUrl;
  final String firstName;
  final String lastName;
  final String phone;
  final String jobTitle;
  final String location;

  const ProfileModel({
    required this.uid,
    required this.role,
    required this.email,
    this.photoUrl = '',
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.jobTitle = '',
    this.location = '',
  });

  String get fullName {
    final parts = [
      firstName.trim(),
      lastName.trim(),
    ].where((s) => s.isNotEmpty);
    final name = parts.join(' ');
    return name.isNotEmpty ? name : '—';
  }

  ProfileModel copyWith({
    String? uid,
    String? role,
    String? email,
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? phone,
    String? jobTitle,
    String? location,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      jobTitle: jobTitle ?? this.jobTitle,
      location: location ?? this.location,
    );
  }

  factory ProfileModel.fromMap({
    required String uid,
    required String fallbackEmail,
    required bool isProvider,
    required Map<String, dynamic> data,
  }) {
    return ProfileModel(
      uid: uid,
      role: (data['role'] ?? (isProvider ? 'provider' : 'user')).toString(),
      email: (data['email'] ?? fallbackEmail).toString(),
      photoUrl: (data['photoUrl'] ?? '').toString(),
      firstName: (data['firstName'] ?? '').toString(),
      lastName: (data['lastName'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      jobTitle: (data['jobTitle'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toFirestore({required bool isProvider}) {
    final map = <String, dynamic>{
      'uid': uid,
      'email': email,
      'role': isProvider ? 'provider' : 'user',
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'phone': phone.trim(),
    };

    final url = photoUrl.trim();
    if (url.isNotEmpty) {
      map['photoUrl'] = url;
    }

    if (isProvider) {
      map['jobTitle'] = jobTitle.trim();
      map['location'] = location.trim();
    }

    return map;
  }
}
