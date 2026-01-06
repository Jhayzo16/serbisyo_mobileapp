import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';

const List<ServiceItemModel> carRepairServices = [
  ServiceItemModel(
    name: 'Car Repair',
    description: 'Inspection, oil change, brake adjustment, minor mechanical repairs.',
    price: 1500,
    duration: '2-3 hours',
    rating: 4.5,
    icon: Icons.build,
  ),
  ServiceItemModel(
    name: 'Motorcycle Repair',
    description: 'Tune-ups, tire replacement, chain adjustment, battery issues.',
    price: 800,
    duration: '1-2 hours',
    rating: 4.5,
    icon: Icons.two_wheeler,
  ),
  ServiceItemModel(
    name: 'Car Wash & Detailing',
    description: 'Regular wash, waxing, interior vacuum, dashboard cleaning.',
    price: 500,
    duration: '1-2 hours',
    rating: 4.5,
    icon: Icons.local_car_wash,
  ),
  ServiceItemModel(
    name: 'Tire Change & Vulcanizing',
    description: 'Flat tire repair, replacement, balancing.',
    price: 400,
    duration: '30-60 mins',
    rating: 4.5,
    icon: Icons.tire_repair,
  ),
];
