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
    apiKey: 'AIzaSyDeXVG81Ld9idu9rOIymLvPvR-RElwQihQ',
    appId: '1:386553724163:web:99afb997a9ebeb74bf3d36',
    messagingSenderId: '386553724163',
    projectId: 'exora-map-project',
    authDomain: 'exora-map-project.firebaseapp.com',
    storageBucket: 'exora-map-project.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCpDbdAH6M4vpRdsFTxG3YieyjmTw7rMso',
    appId: '1:386553724163:android:0c808ed2db77c54cbf3d36',
    messagingSenderId: '386553724163',
    projectId: 'exora-map-project',
    storageBucket: 'exora-map-project.firebasestorage.app',
  );
}
