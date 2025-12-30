import 'package:flutter/material.dart';

class CleaningServiceModel {
  final String name;
  final String description;
  final int price;
  final String duration;
  final double rating;
  final IconData icon;

  const CleaningServiceModel({
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.rating,
    required this.icon,
  });
}