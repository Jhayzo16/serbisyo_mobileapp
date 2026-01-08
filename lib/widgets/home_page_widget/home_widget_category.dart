import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/service_categories_page.dart';
import 'package:serbisyo_mobileapp/pages/service_category_page.dart';
import 'package:serbisyo_mobileapp/services/home_category_service.dart';
import 'package:serbisyo_mobileapp/widgets/home_page_widget/home_category_card.dart';

class HomeWidgetCategory extends StatelessWidget {
  const HomeWidgetCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryService = const HomeCategoryService();
    final categories = categoryService.featuredCategories();

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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ServiceCategoriesPage(),
                    ),
                  );
                },
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
            children: List.generate(
              categories.length,
              (i) {
                final category = categories[i];
                return HomeCategoryCard(
                  label: category.label,
                  iconAsset: category.iconAsset,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ServiceCategoryPage(
                          title: category.title,
                          services: category.services,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
