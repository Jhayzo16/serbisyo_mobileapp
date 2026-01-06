import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';

const List<ServiceItemModel> constructionLaborServices = [
  ServiceItemModel(
    name: 'Carpentry',
    description: 'Furniture making, repairs, and wood installations.',
    price: 1500,
    duration: '2-3 hours',
    rating: 4.5,
    icon: Icons.carpenter_outlined,
  ),
  ServiceItemModel(
    name: 'Masonry',
    description: 'Concrete work, tiling, and wall repairs.',
    price: 1800,
    duration: '3-5 hours',
    rating: 4.5,
    icon: Icons.construction_outlined,
  ),
  ServiceItemModel(
    name: 'Painting Services',
    description: 'Interior and exterior painting.',
    price: 1200,
    duration: '3-5 hours',
    rating: 4.5,
    icon: Icons.format_paint_outlined,
  ),
  ServiceItemModel(
    name: 'Roof Repair',
    description: 'Fix leaks, damaged sheets, and roofing maintenance.',
    price: 2000,
    duration: '3-6 hours',
    rating: 4.5,
    icon: Icons.home_repair_service_outlined,
  ),
  ServiceItemModel(
    name: 'Welding Services',
    description: 'Metal fabrication and repair works.',
    price: 1800,
    duration: '2-4 hours',
    rating: 4.5,
    icon: Icons.handyman_outlined,
  ),
];
