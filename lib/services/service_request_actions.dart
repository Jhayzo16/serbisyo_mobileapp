import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';
import 'package:serbisyo_mobileapp/pages/succesful_request_page.dart';
import 'package:serbisyo_mobileapp/services/request_service.dart';

class ServiceRequestActions {
  ServiceRequestActions({RequestService? requestService, ImagePicker? picker})
    : _requestService = requestService ?? RequestService(),
      _picker = picker ?? ImagePicker();

  final RequestService _requestService;
  final ImagePicker _picker;

  Future<List<XFile>> pickImages(BuildContext context) async {
    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 1024,
        imageQuality: 85,
      );
      return List<XFile>.unmodifiable(picked);
    } catch (_) {
      if (!context.mounted) return const <XFile>[];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick images')));
      return const <XFile>[];
    }
  }

  Future<String?> findCurrentLocationLabel(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Please enable Location services')),
        );
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return null;
      }
      if (permission == LocationPermission.deniedForever) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Location permission permanently denied'),
          ),
        );
        return null;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));
      } on TimeoutException {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Unable to determine location. Try again.'),
          ),
        );
        return null;
      }

      final fallback =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      var label = fallback;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String?>[
            p.name,
            p.subLocality,
            p.locality,
            p.administrativeArea,
          ].where((e) => e != null && e.trim().isNotEmpty).toList();
          if (parts.isNotEmpty) label = parts.join(', ');
        }
      } catch (_) {
        // Keep lat/lng fallback if reverse-geocoding fails.
      }

      return label;
    } catch (e) {
      if (!context.mounted) return null;
      messenger.showSnackBar(SnackBar(content: Text(_locationErrorMessage(e))));
      return null;
    }
  }

  Future<void> submitServiceRequest(
    BuildContext context, {
    required ServiceItemModel service,
    required DateTime? date,
    required TimeOfDay? time,
    required String location,
    required String notes,
    required List<XFile> images,
  }) async {
    try {
      await _requestService.submitServiceRequest(
        service: service,
        date: date,
        time: time,
        location: location,
        notes: notes,
        images: images,
      );

      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SuccesfulRequestPage()),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to submit request')));
    }
  }

  String _locationErrorMessage(Object e) {
    if (e is LocationServiceDisabledException) {
      return 'Please enable Location services';
    }
    if (e is PermissionDeniedException) {
      return 'Location permission denied';
    }
    if (e is TimeoutException) {
      return 'Location request timed out. Try again.';
    }
    return 'Failed to get location. Check GPS and internet.';
  }
}
