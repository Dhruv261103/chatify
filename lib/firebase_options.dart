// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZpGbP8S_DBSof4M2k5Hj60J3n52B2qF8',
    appId: '1:905254753939:android:3627cff6d7f2f7296b5f66',
    messagingSenderId: '905254753939',
    projectId: 'chatify-b1de0',
    storageBucket: 'chatify-b1de0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkj2ltCUII9YiQXFClL3VQ9Huk-RiJBLE',
    appId: '1:905254753939:ios:38c4727dc9766b816b5f66',
    messagingSenderId: '905254753939',
    projectId: 'chatify-b1de0',
    storageBucket: 'chatify-b1de0.appspot.com',
    androidClientId: '905254753939-0tnmjjtl1gb38ttkovaiu0dbem2237d1.apps.googleusercontent.com',
    iosClientId: '905254753939-2strda0r4326g7cut7c6run99509sk39.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatify',
  );
}
