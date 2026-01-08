import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serbisyo_mobileapp/models/customreq_model.dart';
import 'package:serbisyo_mobileapp/models/service_item_model.dart';
import 'package:serbisyo_mobileapp/services/storage_service.dart';

class RequestService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final StorageService _storage;

  RequestService({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
    StorageService? storage,
  }) : _db = db ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? StorageService();

  String get _userId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    return uid;
  }

  String _iconAssetForServiceName(String name) {
    final n = name.trim().toLowerCase();

    // Cleaning
    if (n.contains('window')) return 'assets/icons/window_cleaning_icon.png';
    if (n.contains('deep')) return 'assets/icons/deep_cleaning_icon.png';
    if (n.contains('clean')) return 'assets/icons/cleaning_icon.png';

    // Plumbing
    if (n.contains('leak')) return 'assets/icons/leak_repair_icon.png';
    if (n.contains('toilet')) return 'assets/icons/toilet_repair_icon.png';
    if (n.contains('pipe')) return 'assets/icons/pipe_installation_icon.png';
    if (n.contains('plumb')) return 'assets/icons/plumbing_icon.png';

    // Quick errands
    if (n.contains('grocery')) return 'assets/icons/grocery_icon.png';
    if (n.contains('market'))
      return 'assets/icons/publicmarket_errand_icon.png';
    if (n.contains('bill')) return 'assets/icons/billpayment_icon.png';
    if (n.contains('errand')) return 'assets/icons/errand_icon.png';

    // Pet care
    if (n.contains('pet')) return 'assets/icons/pet_icon.png';

    // Beauty & wellness
    if (n.contains('haircut')) return 'assets/icons/Beauty.png';
    if (n.contains('nail')) return 'assets/icons/Beauty.png';
    if (n.contains('massage')) return 'assets/icons/Beauty.png';

    // Airconditioning
    if (n.contains('aircon')) return 'assets/icons/Aircon.png';
    if (n.contains('air') && n.contains('conditioning')) {
      return 'assets/icons/Aircon.png';
    }

    // Car repair
    if (n.contains('motorcycle')) return 'assets/icons/carr_repair.png';
    if (n.contains('vulcan')) return 'assets/icons/carr_repair.png';
    if (n.contains('tire')) return 'assets/icons/carr_repair.png';
    if (n.contains('car') && n.contains('wash'))
      return 'assets/icons/carr_repair.png';
    if (n.contains('car') && n.contains('repair'))
      return 'assets/icons/carr_repair.png';

    // Delivery
    if (n.contains('delivery')) return 'assets/icons/car_icon.png';
    if (n.contains('package')) return 'assets/icons/car_icon.png';

    // Construction & labor
    if (n.contains('carpentry')) return 'assets/icons/Construction.png';
    if (n.contains('masonry')) return 'assets/icons/Construction.png';
    if (n.contains('painting')) return 'assets/icons/Construction.png';
    if (n.contains('roof')) return 'assets/icons/Construction.png';
    if (n.contains('welding')) return 'assets/icons/Construction.png';

    // Default
    return 'assets/icons/custom_icon.png';
  }

  Future<String> submitCustomRequest({
    required CustomRequestModel request,
    required List<XFile> images,
  }) async {
    final ref = _db.collection('requests').doc();
    final requestId = ref.id;

    final imageUrls = <String>[];
    for (final file in images) {
      final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = 'requests/$requestId/$safeName';
      final url = await _storage.uploadXFile(file: file, storagePath: path);
      imageUrls.add(url);
    }

    await ref.set({
      'type': 'custom',
      'userId': _userId,
      'status': 'pending',
      'iconAssetPath': 'assets/icons/custom_icon.png',
      'createdAt': FieldValue.serverTimestamp(),
      'createdAtClient': Timestamp.now(),
      ...request.toJson(),
      'imageUrls': imageUrls,
    });

    return requestId;
  }

  Future<String> submitServiceRequest({
    required ServiceItemModel service,
    required DateTime? date,
    required TimeOfDay? time,
    required String location,
    required String notes,
    required List<XFile> images,
  }) async {
    final ref = _db.collection('requests').doc();
    final requestId = ref.id;

    final imageUrls = <String>[];
    for (final file in images) {
      final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = 'requests/$requestId/$safeName';
      final url = await _storage.uploadXFile(file: file, storagePath: path);
      imageUrls.add(url);
    }

    await ref.set({
      'type': 'service',
      'userId': _userId,
      'status': 'pending',
      'iconAssetPath': _iconAssetForServiceName(service.name),
      'createdAt': FieldValue.serverTimestamp(),
      'createdAtClient': Timestamp.now(),
      'service': {
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'duration': service.duration,
        'rating': service.rating,
      },
      'date': date?.toIso8601String(),
      'time': time != null ? '${time.hour}:${time.minute}' : null,
      'location': location,
      'notes': notes,
      'imageUrls': imageUrls,
    });

    return requestId;
  }
}
