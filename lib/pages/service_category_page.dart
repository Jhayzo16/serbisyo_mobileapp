import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';
import 'package:serbisyo_mobileapp/pages/service_request_page.dart';
import 'package:serbisyo_mobileapp/widgets/services_card_widget/service_item_card.dart';

class ServiceCategoryPage extends StatefulWidget {
  final String title;
  final List<ServiceItemModel> services;
  final int? initialSelectedIndex;

  const ServiceCategoryPage({
    super.key,
    required this.title,
    required this.services,
    this.initialSelectedIndex,
  });

  @override
  State<ServiceCategoryPage> createState() => _ServiceCategoryPageState();
}

class _ServiceCategoryPageState extends State<ServiceCategoryPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.services.isEmpty) {
      _selectedIndex = -1;
      return;
    }

    final requested = widget.initialSelectedIndex;
    if (requested == null) {
      _selectedIndex = 0;
      return;
    }

    _selectedIndex = requested.clamp(0, widget.services.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff254356),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 70, left: 40, right: 20),
              child: const Text(
                'Description of Service',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff254356),
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 18),
              itemCount: widget.services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final service = widget.services[index];
                return ServiceItemCard(
                  service: service,
                  selected: index == _selectedIndex,
                  onTap: () {
                    setState(() => _selectedIndex = index);
                  },
                );
              },
            ),
            const SizedBox(height: 40),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, bottom: 24),
                child: Center(
                  child: SizedBox(
                    height: 48,
                    width: 210,
                    child: ElevatedButton(
                      onPressed: widget.services.isEmpty || _selectedIndex < 0
                          ? null
                          : () {
                              final selectedService =
                                  widget.services[_selectedIndex];
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ServiceRequestPage(
                                    service: selectedService,
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff356785),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
