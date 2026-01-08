import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/services/custom_request_actions.dart';
import 'package:serbisyo_mobileapp/widgets/custom_request_page_widget/custom_request_form.dart';

class CustomRequestPage extends StatelessWidget {
  final RequestSubmitter submitter;
  const CustomRequestPage({
    super.key,
    this.submitter = const LocalRequestSubmitter(),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text(
          'Custom Request Service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 18),
                CustomRequestForm(submitter: submitter),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
