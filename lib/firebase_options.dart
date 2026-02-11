import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for this project.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZovD7dO7yhC9m5LRRqxk2QyVB3ipPjgI',
    appId: '1:255572322943:android:a8690862834a516d08ad4a',
    messagingSenderId: '255572322943',
    projectId: 'kisan-mitra-8cc98',
    storageBucket: 'kisan-mitra-8cc98.firebasestorage.app',
  );
}
