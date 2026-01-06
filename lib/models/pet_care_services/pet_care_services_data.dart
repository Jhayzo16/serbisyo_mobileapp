import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';

const List<ServiceItemModel> petCareServices = [
  ServiceItemModel(
    name: 'Pet Training',
    description: 'Basic obedience training and behavior guidance for your pet.',
    price: 500,
    duration: '1-2 hours',
    rating: 4.5,
    icon: Icons.school_outlined,
  ),
  ServiceItemModel(
    name: 'Pet Checkup',
    description: 'Basic pet health check and wellness guidance.',
    price: 600,
    duration: '30-60 mins',
    rating: 4.5,
    icon: Icons.medical_services_outlined,
  ),
  ServiceItemModel(
    name: 'Pet Grooming',
    description: 'Bath, nail trimming, ear cleaning, and basic grooming.',
    price: 450,
    duration: '1-2 hours',
    rating: 4.5,
    icon: Icons.content_cut_outlined,
  ),
];
