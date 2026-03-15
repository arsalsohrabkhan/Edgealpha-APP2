// Auto-configured from your google-services.json
// Project: alphaedge-993e2  |  Android only

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not configured.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Only Android is configured in this build.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'AIzaSyAEOwy9--pCRBU2RxVcEpXp4NBmQQncUqQ',
    appId:             '1:1060470776027:android:ec91a060348c9cd616ecfe',
    messagingSenderId: '1060470776027',
    projectId:         'alphaedge-993e2',
    storageBucket:     'alphaedge-993e2.firebasestorage.app',
  );
}
