import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with [Firebase.initializeApp].
///
/// Generated manually from android/app/google-services.json.
/// If you add iOS/Web/Desktop Firebase apps later, add their options here.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions have not been configured for web in this project.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'FirebaseOptions have not been configured for this platform in this project.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Fuchsia is not supported.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAxm-EI5WHkGHOKCTud3HfgAJGmb_7hWl8',
    appId: '1:274354131786:android:c9e3bdb6b9576c0ea3e7b3',
    messagingSenderId: '274354131786',
    projectId: 'serbisyomobileapp',
    storageBucket: 'serbisyomobileapp.firebasestorage.app',
  );
}
