import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';

const List<ServiceItemModel> plumbingServices = [
  ServiceItemModel(
    name: 'Leak Repair',
    description: 'Fixing leaking pipes and faucets',
    price: 800,
    rating: 4.5,
    icon: Icons.plumbing,
  ),
  ServiceItemModel(
    name: 'Toilet Repair',
    description: 'Thorough cleaning of different surfaces',
    price: 1200,
    rating: 4.5,
    icon: Icons.wc,
  ),
  ServiceItemModel(
    name: 'Pipe installation',
    description: 'Installation of new pipes',
    price: 2500,
    rating: 4.5,
    icon: Icons.build,
  ),
];
