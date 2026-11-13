import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for Exora.
/// Run `flutterfire configure` to generate project-specific production credentials.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for Android and Web in this project.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderKeyForExoraAppWeb',
    appId: '1:1234567890:web:demo123456',
    messagingSenderId: '1234567890',
    projectId: 'demo-exora-map',
    authDomain: 'demo-exora-map.firebaseapp.com',
    storageBucket: 'demo-exora-map.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderKeyForExoraAppAndroid',
    appId: '1:1234567890:android:demo123456',
    messagingSenderId: '1234567890',
    projectId: 'demo-exora-map',
    storageBucket: 'demo-exora-map.appspot.com',
  );
}
