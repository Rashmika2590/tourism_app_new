// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      return web;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB4b8n2nrH4RxAWQysuST90hFVndcq_JDo',
    appId: '1:1094004848939:web:a8eb93ef856fb043af6d6e',
    messagingSenderId: '1094004848939',
    projectId: 'uexplustourismapp',
    authDomain: 'uexplustourismapp.firebaseapp.com',
    storageBucket: 'uexplustourismapp.firebasestorage.app',
    measurementId: 'G-SZN29WJZJE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCR6eR9hilQmzDSas_KxxU2uVbE5EmS80',
    appId: '1:1094004848939:android:bc6aab66bdeb498faf6d6e',
    messagingSenderId: '1094004848939',
    projectId: 'uexplustourismapp',
    storageBucket: 'uexplustourismapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZosTmzUsDrcjTZxc5efMX2Ot-NYB7Biw',
    appId: '1:1094004848939:ios:061d98278e774ddfaf6d6e',
    messagingSenderId: '1094004848939',
    projectId: 'uexplustourismapp',
    storageBucket: 'uexplustourismapp.firebasestorage.app',
    iosClientId: '1094004848939-1ka7biqnvcqqhp3l71pp5lsj897ufee7.apps.googleusercontent.com',
    iosBundleId: 'com.example.tourismAppNew',
  );
}
