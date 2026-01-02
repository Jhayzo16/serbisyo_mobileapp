import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/service_category_page.dart';
import 'package:serbisyo_mobileapp/models/cleaning_services/cleaning_services_data.dart';
import 'package:serbisyo_mobileapp/models/plumbing_services/plumbing_services_data.dart';
import 'package:serbisyo_mobileapp/models/quick_errand_services/quick_errand_services_data.dart';

class HomeWidgetCategory extends StatelessWidget {
  const HomeWidgetCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'Cleaning', 'icon': 'assets/icons/cleaning_icon.png'},
      {'label': 'Plumbing', 'icon': 'assets/icons/plumbing_icon.png'},
      {'label': 'Quick Errand', 'icon': 'assets/icons/errand_icon.png'},
      {'label': 'Pet Care', 'icon': 'assets/icons/pet_icon.png'},
      {'label': 'Car Repair', 'icon': 'assets/icons/carr_repair.png'},
      {'label': 'Delivery', 'icon': 'assets/icons/car_icon.png'},
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
        _ => null,
      };

      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
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
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Services Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff254356),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See more',
                  style: TextStyle(color: Color(0xff9B9B9B), fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
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
        ],
      ),
    );
  }
}
