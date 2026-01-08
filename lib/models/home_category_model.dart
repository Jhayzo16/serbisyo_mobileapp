import 'package:serbisyo_mobileapp/models/service_item_model.dart';

class HomeCategoryModel {
  const HomeCategoryModel({
    required this.label,
    required this.iconAsset,
    required this.title,
    required this.services,
  });

  final String label;
  final String iconAsset;
  final String title;
  final List<ServiceItemModel> services;
}
