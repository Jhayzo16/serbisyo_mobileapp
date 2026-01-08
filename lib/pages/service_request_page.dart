import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';
import 'package:serbisyo_mobileapp/widgets/service_request_page_widget/service_request_form.dart';
import 'package:serbisyo_mobileapp/widgets/service_request_page_widget/service_request_summary_card.dart';

class ServiceRequestPage extends StatelessWidget {
  final ServiceItemModel service;

  const ServiceRequestPage({super.key, required this.service});

  String _formatPeso(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    return '₱$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff254356),
          ),
          'Request Service',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceRequestSummaryCard(
              service: service,
              formatPeso: _formatPeso,
            ),
            Container(
              margin: EdgeInsets.only(top: 30, left: 40, right: 40),
              child: Text(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff254356),
                ),
                'Date & time',
              ),
            ),
            ServiceRequestForm(service: service),
          ],
        ),
      ),
    );
  }
}
