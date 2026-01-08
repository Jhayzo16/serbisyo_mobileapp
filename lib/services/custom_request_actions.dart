import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serbisyo_mobileapp/models/customreq_model.dart';
import 'package:serbisyo_mobileapp/pages/succesful_request_page.dart';
import 'package:serbisyo_mobileapp/services/request_service.dart';

abstract class RequestSubmitter {
  const RequestSubmitter();
  Future<void> submit(CustomRequestModel request, BuildContext context);
}

class LocalRequestSubmitter implements RequestSubmitter {
  const LocalRequestSubmitter();

  @override
  Future<void> submit(CustomRequestModel request, BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await Future.delayed(const Duration(milliseconds: 300));
    messenger.showSnackBar(const SnackBar(content: Text('Request submitted')));
  }
}

class FirestoreRequestSubmitter implements RequestSubmitter {
  final List<XFile> images;
  const FirestoreRequestSubmitter({required this.images});

  @override
  Future<void> submit(CustomRequestModel request, BuildContext context) async {
    final service = RequestService();
    try {
      await service.submitCustomRequest(request: request, images: images);
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SuccesfulRequestPage()),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to submit request')));
    }
  }
}
