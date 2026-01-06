import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';

const List<ServiceItemModel> airconditioningServices = [
  ServiceItemModel(
    name: 'Aircon Cleaning',
    description:
        'Cleaning and basic maintenance to improve cooling performance.',
    price: 800,
    duration: '1-2 hours',
    rating: 4.5,
    icon: Icons.ac_unit,
  ),
  ServiceItemModel(
    name: 'Aircon Repair',
    description: 'Troubleshooting and minor repairs for common aircon issues.',
    price: 1500,
    duration: '2-3 hours',
    rating: 4.5,
    icon: Icons.build_outlined,
  ),
];
