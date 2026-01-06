import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:serbisyo_mobileapp/services/cloudinary_config.dart';

class StorageService {
  StorageService();

  Future<String> uploadXFile({
    required XFile file,
    required String storagePath,
  }) async {
    CloudinaryConfig.validate();

    final bytes = await file.readAsBytes();
    final contentType = lookupMimeType(file.name) ?? 'application/octet-stream';

    final cloudName = CloudinaryConfig.cloudName.trim();
    final preset = CloudinaryConfig.uploadPreset.trim();

    final normalizedPath = storagePath.replaceAll('\\', '/');
    final lastSlash = normalizedPath.lastIndexOf('/');
    final folder = lastSlash > 0 ? normalizedPath.substring(0, lastSlash) : '';
    final filename = (file.name.trim().isNotEmpty)
        ? file.name.trim()
        : 'upload_${DateTime.now().millisecondsSinceEpoch}';

    final dot = filename.lastIndexOf('.');
    final publicId = dot > 0 ? filename.substring(0, dot) : filename;

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    try {
      if (kDebugMode) {
        debugPrint(
          'Uploading to Cloudinary: cloud=$cloudName folder=$folder public_id=$publicId path=$storagePath name=${file.name}',
        );
      }

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = preset
        ..fields['resource_type'] = 'image';

      if (folder.trim().isNotEmpty) {
        request.fields['folder'] = folder;
      }
      if (publicId.trim().isNotEmpty) {
        request.fields['public_id'] = publicId;
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          'Cloudinary upload failed (${response.statusCode}): ${response.body}',
        );
      }

      final data = jsonDecode(response.body);
      final url = (data is Map<String, dynamic>) ? (data['secure_url'] as String?) : null;
      if (url == null || url.trim().isEmpty) {
        throw StateError('Cloudinary upload succeeded but no secure_url returned.');
      }
      return url;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'Cloudinary upload failed: $e (path=$storagePath contentType=$contentType)',
        );
      }

      // Let callers show a message.
      rethrow;
    }
  }
}
