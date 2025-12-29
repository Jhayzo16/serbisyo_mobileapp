import 'package:flutter/material.dart';

/// Model representing the custom request payload.
class CustomRequestModel {
  final String title;
  final String description;
  final DateTime? date;
  final TimeOfDay? time;
  final String location;
  final String budget;
  final List<String> images;

  const CustomRequestModel({
    required this.title,
    required this.description,
    this.date,
    this.time,
    required this.location,
    required this.budget,
    required this.images,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'date': date?.toIso8601String(),
        'time': time != null ? '${time!.hour}:${time!.minute}' : null,
        'location': location,
        'budget': budget,
        'images': images,
      };
}
