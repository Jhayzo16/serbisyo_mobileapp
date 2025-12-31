import 'package:flutter/material.dart';

class ServiceItemModel {
  final String name;
  final String description;
  final int price;
  final String? duration;
  final double rating;
  final IconData icon;

  const ServiceItemModel({
    required this.name,
    required this.description,
    required this.price,
    this.duration,
    required this.rating,
    required this.icon,
  });
}
