import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';

const List<ServiceItemModel> quickErrandServices = [
  ServiceItemModel(
    name: 'Grocery Run',
    description: 'Buying and delivering groceries',
    price: 300,
    rating: 4.5,
    icon: Icons.shopping_cart,
  ),
  ServiceItemModel(
    name: 'Public Market Errand',
    description: 'Thorough cleaning of different surfaces',
    price: 200,
    rating: 4.5,
    icon: Icons.storefront,
  ),
  ServiceItemModel(
    name: 'Bill Payment',
    description: 'Paying bills on your behalf',
    price: 200,
    rating: 4.5,
    icon: Icons.payments,
  ),
];
