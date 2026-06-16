// GENERATED — replace this file by running:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// That command will:
//   1. Ask you to select your Firebase project
//   2. Generate google-services.json (Android) and GoogleService-Info.plist (iOS)
//   3. Overwrite this file with your real Firebase options
//
// Until then the app will throw at launch if you run it with this placeholder.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  // ⚠️  Replace these placeholder values with your real Firebase config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAh_R2C30NNb-AniOkQrkBnOYiEi8QF2eg',
    appId: '1:187703569206:android:08825b230f5f80e25b2197',
    messagingSenderId: '187703569206',
    projectId: 'profits-alerts',
    storageBucket: 'profits-alerts.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBRizL_a-g1js81TORSL21alQjuaomgTcM',
    appId: '1:187703569206:ios:ca6163cf737b01225b2197',
    messagingSenderId: '187703569206',
    projectId: 'profits-alerts',
    storageBucket: 'profits-alerts.firebasestorage.app',
    iosBundleId: 'com.profitalerts.profitalerts',
  );

}