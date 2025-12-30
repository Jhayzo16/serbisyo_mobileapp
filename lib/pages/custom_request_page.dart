import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:serbisyo_mobileapp/models/customreq_model.dart';


abstract class RequestSubmitter {
  const RequestSubmitter();
  Future<void> submit(CustomRequestModel request, BuildContext context);
}


class LocalRequestSubmitter implements RequestSubmitter {
  const LocalRequestSubmitter();
  @override
  Future<void> submit(CustomRequestModel request, BuildContext context) async {

    final messenger = ScaffoldMessenger.of(context);
    await Future.delayed(Duration(milliseconds: 300));
    messenger.showSnackBar(
      SnackBar(content: Text('Request submitted')),
    );
  }
}


class CustomRequestPage extends StatelessWidget {
  final RequestSubmitter submitter;
  const CustomRequestPage({super.key, this.submitter = const LocalRequestSubmitter()});

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
class CustomRequestForm extends StatefulWidget {
  final RequestSubmitter submitter;
  const CustomRequestForm({super.key, required this.submitter});

  @override
  State<CustomRequestForm> createState() => _CustomRequestFormState();
}

class _CustomRequestFormState extends State<CustomRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();

  bool _isFindingLocation = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final List<String> _images = [];

  Color get primaryColor => const Color(0xFF2D6B7A);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
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

  void _addMockImage() {
   
    setState(() => _images.add('photo_${_images.length + 1}.jpg'));
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

      final fallback = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
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
      messenger.showSnackBar(
        SnackBar(content: Text(_locationErrorMessage(e))),
      );
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
      hintStyle: TextStyle(color: Color(0xFF6B7280)),
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
    if (!_formKey.currentState!.validate()) return;

    final model = CustomRequestModel(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      time: _selectedTime,
      location: _locationController.text.trim(),
      budget: _budgetController.text.trim(),
      images: List.unmodifiable(_images),
    );

    await widget.submitter.submit(model, context);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Title', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            decoration: _inputDecoration(hint: 'e.g., Electrical Service'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
          ),

          SizedBox(height: 16),
          Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            decoration: _inputDecoration(hint: 'e.g., I need an electrician to fix a wiring problem and install some outlets'),
            keyboardType: TextInputType.multiline,
            minLines: 4,
            maxLines: 8,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
          ),

          SizedBox(height: 16),
          Text('Date & time', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: _inputDecoration(
                        hint: _formatDate(),
                        suffix: Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.calendar_today_outlined, color: primaryColor),
                        ),
                      ),
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
                      decoration: _inputDecoration(
                        hint: _formatTime(),
                        suffix: Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.access_time_outlined, color: primaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),
          Text('Location', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _findCurrentLocation,
            child: AbsorbPointer(
              child: TextFormField(
                controller: _locationController,
                decoration: _inputDecoration(
                  hint: 'Find your location',
                  suffix: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: _isFindingLocation
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(primaryColor),
                            ),
                          )
                        : Icon(Icons.location_on_outlined, color: primaryColor),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a location' : null,
              ),
            ),
          ),

          SizedBox(height: 16),
          Text('Budget(optional)', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          TextFormField(
            controller: _budgetController,
            decoration: _inputDecoration(hint: 'Enter Ideal Budget'),
            keyboardType: TextInputType.number,
          ),

          SizedBox(height: 16),
          InkWell(
            onTap: _addMockImage,
            child: Row(
              children: [
                Icon(Icons.upload_file_outlined, color: Color(0xFF6B7280)),
                SizedBox(width: 8),
                Text('Upload photo', style: TextStyle(color: Color(0xFF6B7280))),
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
                  child: Center(child: Text(_images[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 10))),
                ),
                separatorBuilder: (context, index) => SizedBox(width: 8),
                itemCount: _images.length,
              ),
            ),
          ],

          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(

                'Submit Request', style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
  }