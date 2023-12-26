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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyB0s9gs4he6A8kIlt-2u4BiP7bLD1ptGf8',
    appId: '1:169506678205:web:021e73b2feffda6a151ed4',
    messagingSenderId: '169506678205',
    projectId: 'splitwise-adcc0',
    authDomain: 'splitwise-adcc0.firebaseapp.com',
    storageBucket: 'splitwise-adcc0.appspot.com',
    measurementId: 'G-QPNJ1145JG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlEBA-h6ptGswO9qyVY0oPS80sjkB6f78',
    appId: '1:169506678205:android:89d07bffc6b4e543151ed4',
    messagingSenderId: '169506678205',
    projectId: 'splitwise-adcc0',
    storageBucket: 'splitwise-adcc0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCV7QpJxo7Z2qpKh-Ip3B_Vk42ZeaUdsIc',
    appId: '1:169506678205:ios:b082347f22bfc634151ed4',
    messagingSenderId: '169506678205',
    projectId: 'splitwise-adcc0',
    storageBucket: 'splitwise-adcc0.appspot.com',
    androidClientId: '169506678205-l9j7qh02k4qeppjm7h8jv6q9biilbmte.apps.googleusercontent.com',
    iosClientId: '169506678205-q6lhgrtn1ar7cig3qe5d9t77l3mkd7m5.apps.googleusercontent.com',
    iosBundleId: 'com.example.untitled6',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCV7QpJxo7Z2qpKh-Ip3B_Vk42ZeaUdsIc',
    appId: '1:169506678205:ios:ebbd12fa82b5c970151ed4',
    messagingSenderId: '169506678205',
    projectId: 'splitwise-adcc0',
    storageBucket: 'splitwise-adcc0.appspot.com',
    androidClientId: '169506678205-l9j7qh02k4qeppjm7h8jv6q9biilbmte.apps.googleusercontent.com',
    iosClientId: '169506678205-st1mrhaghmcb3h29302bhifslc959s04.apps.googleusercontent.com',
    iosBundleId: 'com.example.untitled6.RunnerTests',
  );
}
