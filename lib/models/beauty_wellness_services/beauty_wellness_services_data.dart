import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';

const List<ServiceItemModel> beautyWellnessServices = [
  ServiceItemModel(
    name: 'Home Service Haircut',
    description: 'Haircut service at your home, basic styling included.',
    price: 250,
    duration: '30-60 mins',
    rating: 4.5,
    icon: Icons.content_cut_outlined,
  ),
  ServiceItemModel(
    name: 'Nail Care',
    description: 'Basic manicure and pedicure service at your home.',
    price: 300,
    duration: '1-2 hours',
    rating: 4.5,
    icon: Icons.spa_outlined,
  ),
  ServiceItemModel(
    name: 'Massage Therapy',
    description: 'Relaxation massage session at your home.',
    price: 600,
    duration: '1 hour',
    rating: 4.5,
    icon: Icons.self_improvement_outlined,
  ),
];
