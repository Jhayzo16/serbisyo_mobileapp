import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';
import 'package:serbisyo_mobileapp/pages/succesful_request_page.dart';
import 'package:serbisyo_mobileapp/services/request_service.dart';

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
            Container(
              margin: EdgeInsets.only(top: 40, left: 40, right: 40),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xffF6F6F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff254356),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Starting at ${_formatPeso(service.price)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff9B9B9B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if ((service.duration ?? '').trim().isNotEmpty) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: Color(0xff9B9B9B),
                        ),
                        SizedBox(width: 8),
                        Text(
                          service.duration!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff9B9B9B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
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

class ServiceRequestForm extends StatefulWidget {
  final ServiceItemModel service;

  const ServiceRequestForm({super.key, required this.service});

  @override
  State<ServiceRequestForm> createState() => _ServiceRequestFormState();
}

class _ServiceRequestFormState extends State<ServiceRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _requestService = RequestService();
  final _picker = ImagePicker();

  bool _isFindingLocation = false;
  bool _isSubmitting = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final List<XFile> _images = [];

  Color get primaryColor => const Color(0xff356785);

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(Duration(days: 365)),
      lastDate: now.add(Duration(days: 365 * 2)),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked.isEmpty) return;
      if (!mounted) return;
      setState(() => _images.addAll(picked));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick images')),
      );
    }
  }

  Future<void> _findCurrentLocation() async {
    if (_isFindingLocation) return;

    setState(() => _isFindingLocation = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        messenger.showSnackBar(
          SnackBar(content: Text('Please enable Location services')),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        messenger.showSnackBar(
          SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        messenger.showSnackBar(
          SnackBar(content: Text('Location permission permanently denied')),
        );
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(Duration(seconds: 10));
      } on TimeoutException {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Unable to determine location. Try again.')),
        );
        return;
      }

      final fallback =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      String label = fallback;

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

      _locationController.text = label;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_locationErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _isFindingLocation = false);
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

  String _formatDate() {
    if (_selectedDate == null) return 'Select date';
    return '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}';
  }

  String _formatTime() {
    if (_selectedTime == null) return 'Select time';
    final t = _selectedTime!;
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${t.minute.toString().padLeft(2, '0')} $ampm';
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      suffixIcon: suffix,
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final location = _locationController.text.trim();
    final notes = _notesController.text.trim();

    setState(() => _isSubmitting = true);
    try {
      await _requestService.submitServiceRequest(
        service: widget.service,
        date: _selectedDate,
        time: _selectedTime,
        location: location,
        notes: notes,
        images: List<XFile>.unmodifiable(_images),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SuccesfulRequestPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit request')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textFieldStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);

    return Container(
      margin: EdgeInsets.only(left: 40, right: 40, top: 12, bottom: 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: textFieldStyle,
                        decoration: _inputDecoration(
                          hint: _formatDate(),
                          suffix: Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.calendar_today_outlined,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        validator: (_) =>
                            _selectedDate == null ? 'Select a date' : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: textFieldStyle,
                        decoration: _inputDecoration(
                          hint: _formatTime(),
                          suffix: Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.access_time_outlined,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        validator: (_) =>
                            _selectedTime == null ? 'Select a time' : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Location', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _findCurrentLocation,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _locationController,
                  style: textFieldStyle,
                  decoration: _inputDecoration(
                    hint: 'Enter address',
                    suffix: Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: _isFindingLocation
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  primaryColor,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.location_on_outlined,
                              color: primaryColor,
                            ),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter a location'
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Additional Notes (optional)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              style: textFieldStyle,
              decoration: _inputDecoration(hint: 'Any special instructions?'),
              minLines: 1,
              maxLines: 3,
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: _pickImages,
              child: Row(
                children: [
                  Icon(Icons.upload_file_outlined, color: Color(0xFF6B7280)),
                  SizedBox(width: 8),
                  Text(
                    'Upload photo',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            if (_images.isNotEmpty) ...[
              SizedBox(height: 12),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (c, i) => Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _images[i].name,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  separatorBuilder: (context, index) => SizedBox(width: 8),
                  itemCount: _images.length,
                ),
              ),
            ],
            SizedBox(height: 28),
            Center(
              child: SizedBox(
                width: 210,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Confirm Request',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
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
