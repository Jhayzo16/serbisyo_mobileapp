import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/airconditioning_services/airconditioning_services_data.dart';
import 'package:serbisyo_mobileapp/models/beauty_wellness_services/beauty_wellness_services_data.dart';
import 'package:serbisyo_mobileapp/models/car_repair_services/car_repair_services_data.dart';
import 'package:serbisyo_mobileapp/models/cleaning_services/cleaning_services_data.dart';
import 'package:serbisyo_mobileapp/models/construction_labor_services/construction_labor_services_data.dart';
import 'package:serbisyo_mobileapp/models/delivery_services/delivery_services_data.dart';
import 'package:serbisyo_mobileapp/models/pet_care_services/pet_care_services_data.dart';
import 'package:serbisyo_mobileapp/models/plumbing_services/plumbing_services_data.dart';
import 'package:serbisyo_mobileapp/models/quick_errand_services/quick_errand_services_data.dart';
import 'package:serbisyo_mobileapp/pages/service_category_page.dart';
import 'package:serbisyo_mobileapp/widgets/app_elevated_card.dart';

class ServiceCategoriesPage extends StatelessWidget {
  const ServiceCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'Cleaning', 'icon': 'assets/icons/cleaning_icon.png'},
      {'label': 'Plumbing', 'icon': 'assets/icons/plumbing_icon.png'},
      {'label': 'Quick Errand', 'icon': 'assets/icons/errand_icon.png'},
      {'label': 'Pet Care', 'icon': 'assets/icons/pet_icon.png'},
      {'label': 'Car Repair', 'icon': 'assets/icons/carr_repair.png'},
      {'label': 'Delivery', 'icon': 'assets/icons/car_icon.png'},
      // Only visible here (See more)
      {'label': 'Airconditioning', 'icon': 'assets/icons/Aircon.png'},
      {'label': 'Beauty & Wellness', 'icon': 'assets/icons/Beauty.png'},
      {'label': 'Construction & Labor', 'icon': 'assets/icons/Construction.png'},
    ];

    Widget buildCategoryItem(String label, String iconAssetPath) {
      final VoidCallback? onTap = switch (label) {
        'Cleaning' => () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ServiceCategoryPage(
                title: 'Cleaning Services',
                services: cleaningServices,
              ),
            ),
          );
        },
        'Plumbing' => () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ServiceCategoryPage(
                title: 'Plumbing Services',
                services: plumbingServices,
              ),
            ),
          );
        },
        'Quick Errand' => () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ServiceCategoryPage(
                title: 'Quick Errand Services',
                services: quickErrandServices,
              ),
            ),
          );
        },
        'Pet Care' => () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ServiceCategoryPage(
                title: 'Pet Care Services',
                services: petCareServices,
              ),
            ),
          );
        },
        'Car Repair' => () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ServiceCategoryPage(
                title: 'Car Repair Services',
                services: carRepairServices,
              ),
            ),
          );
        },
        'Delivery' => () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ServiceCategoryPage(
                title: 'Delivery Services',
                services: deliveryServices,
              ),
            ),
          );
        },
        'Airconditioning' => () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ServiceCategoryPage(
                title: 'Airconditioning Services',
                services: airconditioningServices,
              ),
            ),
          );
        },
        'Beauty & Wellness' => () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ServiceCategoryPage(
                title: 'Beauty & Wellness Services',
                services: beautyWellnessServices,
              ),
            ),
          );
        },
        'Construction & Labor' => () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ServiceCategoryPage(
                title: 'Construction & Labor Services',
                services: constructionLaborServices,
              ),
            ),
          );
        },
        _ => null,
      };

      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppElevatedCard(
              elevation: 6,
              borderRadius: 12,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: Color(0xff356785),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: ImageIcon(
                          AssetImage(iconAssetPath),
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Services Category',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff254356),
          ),
        ),
      ),
      body: SafeArea(
        child: GridView.count(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: categories
              .map(
                (c) => buildCategoryItem(
                  c['label'] as String,
                  c['icon'] as String,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
