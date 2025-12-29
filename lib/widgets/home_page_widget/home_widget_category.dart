import 'package:flutter/material.dart';

class HomeWidgetCategory extends StatelessWidget {
  const HomeWidgetCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'Cleaning', 'icon': Icons.cleaning_services},
      {'label': 'Plumbing', 'icon': Icons.plumbing},
      {'label': 'Quick Errand', 'icon': Icons.directions_run},
      {'label': 'Pet Care', 'icon': Icons.pets},
      {'label': 'Car Repair', 'icon': Icons.build},
      {'label': 'Delivery', 'icon': Icons.local_shipping},
    ];

    Widget buildCategoryItem(String label, IconData icon) {
      return Column(
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
                    child: Icon(icon, size: 36, color: Colors.white),
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
                    c['icon'] as IconData,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
