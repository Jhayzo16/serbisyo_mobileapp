import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';
import 'package:serbisyo_mobileapp/services/service_request_actions.dart';

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
  late final _actions = ServiceRequestActions();

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
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
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
    final picked = await _actions.pickImages(context);
    if (picked.isEmpty) return;
    if (!mounted) return;
    setState(() => _images.addAll(picked));
  }

  Future<void> _findCurrentLocation() async {
    if (_isFindingLocation) return;

    setState(() => _isFindingLocation = true);
    try {
      final label = await _actions.findCurrentLocationLabel(context);
      if (label == null) return;
      _locationController.text = label;
    } finally {
      if (mounted) setState(() => _isFindingLocation = false);
    }
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
      hintStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
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
      await _actions.submitServiceRequest(
        context,
        service: widget.service,
        date: _selectedDate,
        time: _selectedTime,
        location: location,
        notes: notes,
        images: List<XFile>.unmodifiable(_images),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textFieldStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
    );

    return Container(
      margin: const EdgeInsets.only(left: 40, right: 40, top: 12, bottom: 40),
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
                            padding: const EdgeInsets.only(right: 8.0),
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
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: textFieldStyle,
                        decoration: _inputDecoration(
                          hint: _formatTime(),
                          suffix: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
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
            const SizedBox(height: 20),
            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _findCurrentLocation,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _locationController,
                  style: textFieldStyle,
                  decoration: _inputDecoration(
                    hint: 'Enter address',
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
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
            const SizedBox(height: 20),
            const Text(
              'Additional Notes (optional)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              style: textFieldStyle,
              decoration: _inputDecoration(hint: 'Any special instructions?'),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickImages,
              child: const Row(
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
              const SizedBox(height: 12),
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
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemCount: _images.length,
                ),
              ),
            ],
            const SizedBox(height: 28),
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
