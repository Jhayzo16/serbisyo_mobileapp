import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';

const List<ServiceItemModel> deliveryServices = [
  ServiceItemModel(
    name: 'Small Package Delivery',
    description: 'Documents and small items with same-day delivery.',
    price: 150,
    duration: 'Same day',
    rating: 4.5,
    icon: Icons.inventory_2_outlined,
  ),
  ServiceItemModel(
    name: 'Medium Package Delivery',
    description: 'Groceries, boxes, and medium-sized items.',
    price: 250,
    duration: 'Same day',
    rating: 4.5,
    icon: Icons.local_shipping_outlined,
  ),
  ServiceItemModel(
    name: 'Large / Bulk Item Delivery',
    description: 'Appliances, furniture, and business supplies.',
    price: 400,
    duration: 'Same day',
    rating: 4.5,
    icon: Icons.fire_truck_outlined,
  ),
];
