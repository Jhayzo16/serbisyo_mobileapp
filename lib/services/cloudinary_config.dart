class CloudinaryConfig {
  /// Set via: --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name
  static const cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );

  /// Set via: --dart-define=CLOUDINARY_UPLOAD_PRESET=your_unsigned_preset
  ///
  /// This should be an UNSIGNED upload preset (Cloudinary console).
  static const uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: '',
  );

  static void validate() {
    if (cloudName.trim().isEmpty || uploadPreset.trim().isEmpty) {
      throw StateError(
        'Cloudinary is not configured. Provide --dart-define=CLOUDINARY_CLOUD_NAME=... and --dart-define=CLOUDINARY_UPLOAD_PRESET=...'
      );
    }
  }
}
