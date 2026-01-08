import 'package:serbisyo_mobileapp/models/home_category_model.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';

import 'package:serbisyo_mobileapp/models/airconditioning_services/airconditioning_services_data.dart';
import 'package:serbisyo_mobileapp/models/beauty_wellness_services/beauty_wellness_services_data.dart';
import 'package:serbisyo_mobileapp/models/car_repair_services/car_repair_services_data.dart';
import 'package:serbisyo_mobileapp/models/cleaning_services/cleaning_services_data.dart';
import 'package:serbisyo_mobileapp/models/construction_labor_services/construction_labor_services_data.dart';
import 'package:serbisyo_mobileapp/models/delivery_services/delivery_services_data.dart';
import 'package:serbisyo_mobileapp/models/pet_care_services/pet_care_services_data.dart';
import 'package:serbisyo_mobileapp/models/plumbing_services/plumbing_services_data.dart';
import 'package:serbisyo_mobileapp/models/quick_errand_services/quick_errand_services_data.dart';

class HomeCategoryService {
  const HomeCategoryService();

  List<HomeCategoryModel> allCategories() {
    return const [
      HomeCategoryModel(
        label: 'Cleaning',
        iconAsset: 'assets/icons/cleaning_icon.png',
        title: 'Cleaning Services',
        services: cleaningServices,
      ),
      HomeCategoryModel(
        label: 'Plumbing',
        iconAsset: 'assets/icons/plumbing_icon.png',
        title: 'Plumbing Services',
        services: plumbingServices,
      ),
      HomeCategoryModel(
        label: 'Quick Errand',
        iconAsset: 'assets/icons/errand_icon.png',
        title: 'Quick Errand Services',
        services: quickErrandServices,
      ),
      HomeCategoryModel(
        label: 'Pet Care',
        iconAsset: 'assets/icons/pet_icon.png',
        title: 'Pet Care Services',
        services: petCareServices,
      ),
      HomeCategoryModel(
        label: 'Car Repair',
        iconAsset: 'assets/icons/carr_repair.png',
        title: 'Car Repair Services',
        services: carRepairServices,
      ),
      HomeCategoryModel(
        label: 'Delivery',
        iconAsset: 'assets/icons/car_icon.png',
        title: 'Delivery Services',
        services: deliveryServices,
      ),
      HomeCategoryModel(
        label: 'Airconditioning',
        iconAsset: 'assets/icons/Aircon.png',
        title: 'Airconditioning Services',
        services: airconditioningServices,
      ),
      HomeCategoryModel(
        label: 'Beauty & Wellness',
        iconAsset: 'assets/icons/Beauty.png',
        title: 'Beauty & Wellness Services',
        services: beautyWellnessServices,
      ),
      HomeCategoryModel(
        label: 'Construction & Labor',
        iconAsset: 'assets/icons/Construction.png',
        title: 'Construction & Labor Services',
        services: constructionLaborServices,
      ),
    ];
  }

  List<HomeCategoryModel> featuredCategories() {
    const featuredLabels = <String>{
      'Cleaning',
      'Plumbing',
      'Quick Errand',
      'Pet Care',
      'Car Repair',
      'Delivery',
    };

    final all = allCategories();
    return all.where((c) => featuredLabels.contains(c.label)).toList();
  }

  List<HomeCategoryModel> filterByLabel(String rawQuery) {
    final query = rawQuery.toLowerCase().trim();
    if (query.isEmpty) return const [];

    return allCategories()
        .where((c) => c.label.toLowerCase().contains(query))
        .toList();
  }

  HomeCategoryModel? byLabel(String label) {
    for (final category in allCategories()) {
      if (category.label == label) return category;
    }
    return null;
  }

  List<ServiceItemModel> servicesForLabel(String label) {
    final category = byLabel(label);
    if (category == null) return const [];
    return category.services;
  }
}
