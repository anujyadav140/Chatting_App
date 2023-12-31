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
    apiKey: 'AIzaSyC6CCvxci5Br7FEs5dxT_P0QzEzfKmwvu4',
    appId: '1:354644766395:web:effdf39bab969aeda8c39e',
    messagingSenderId: '354644766395',
    projectId: 'chatting-app-cf41d',
    authDomain: 'chatting-app-cf41d.firebaseapp.com',
    storageBucket: 'chatting-app-cf41d.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZ9WIkyBLCN8fxeKRO_pARvm6cHIYMNpM',
    appId: '1:354644766395:android:dcf2393220afd1e4a8c39e',
    messagingSenderId: '354644766395',
    projectId: 'chatting-app-cf41d',
    storageBucket: 'chatting-app-cf41d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBNP_v4Cyeqz2QZ-nimcys2UHLBix8EuUU',
    appId: '1:354644766395:ios:3fe00621670c3d21a8c39e',
    messagingSenderId: '354644766395',
    projectId: 'chatting-app-cf41d',
    storageBucket: 'chatting-app-cf41d.appspot.com',
    iosClientId: '354644766395-4j9m4cchbprbei14evjisoq75m4u7ak5.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBNP_v4Cyeqz2QZ-nimcys2UHLBix8EuUU',
    appId: '1:354644766395:ios:8909f297ad311199a8c39e',
    messagingSenderId: '354644766395',
    projectId: 'chatting-app-cf41d',
    storageBucket: 'chatting-app-cf41d.appspot.com',
    iosClientId: '354644766395-9j21dv2jjlp2aakm6e6cmvvf703f165b.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatApp.RunnerTests',
  );
}
