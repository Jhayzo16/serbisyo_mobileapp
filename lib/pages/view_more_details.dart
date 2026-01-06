import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/widgets/view_more_details/view_details_widget.dart';

class ViewMoreDetails extends StatelessWidget {
  const ViewMoreDetails({super.key, required this.requestId});

  final String requestId;

  static const _titleColor = Color(0xff254356);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Request Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _titleColor,
          ),
        ),
        centerTitle: true,
      ),
      body: ViewDetailsWidget(requestId: requestId),
    );
  }
}