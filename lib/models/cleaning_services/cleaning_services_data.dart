import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';

const List<ServiceItemModel> cleaningServices = [
  ServiceItemModel(
    name: 'House Cleaning',
    description: 'General cleaning of your home',
    price: 1500,
    duration: '2-3 hours',
    rating: 4.5,
    icon: Icons.home,
  ),
  ServiceItemModel(
    name: 'Deep Cleaning',
    description: 'Thorough cleaning of different surfaces',
    price: 2000,
    duration: '3-5 hours',
    rating: 4.5,
    icon: Icons.cleaning_services,
  ),
  ServiceItemModel(
    name: 'Window Cleaning',
    description: 'Cleaning of windows and frames',
    price: 700,
    duration: '1-2 hours',
    rating: 4.5,
    icon: Icons.window,
  ),
];
