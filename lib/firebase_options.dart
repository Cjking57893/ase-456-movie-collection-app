// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
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
    apiKey: 'AIzaSyCtvYEbe_lJxPQE0E5_yXAjNmmwqYCnkxk',
    appId: '1:249286272069:web:1c63e491d311d08fd3af2c',
    messagingSenderId: '249286272069',
    projectId: 'movie-collection-app-cbe7f',
    authDomain: 'movie-collection-app-cbe7f.firebaseapp.com',
    storageBucket: 'movie-collection-app-cbe7f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC9IwWY_1qvo10rU9YfvslOKvDxhoTGPgM',
    appId: '1:249286272069:android:0d4870fc0a7ebccad3af2c',
    messagingSenderId: '249286272069',
    projectId: 'movie-collection-app-cbe7f',
    storageBucket: 'movie-collection-app-cbe7f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSTjHitzQ9M-e_OlS4-1ngms7kWmw4NUU',
    appId: '1:249286272069:ios:9941e5778b6f1a98d3af2c',
    messagingSenderId: '249286272069',
    projectId: 'movie-collection-app-cbe7f',
    storageBucket: 'movie-collection-app-cbe7f.firebasestorage.app',
    iosBundleId: 'com.example.movieCollectionApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDSTjHitzQ9M-e_OlS4-1ngms7kWmw4NUU',
    appId: '1:249286272069:ios:9941e5778b6f1a98d3af2c',
    messagingSenderId: '249286272069',
    projectId: 'movie-collection-app-cbe7f',
    storageBucket: 'movie-collection-app-cbe7f.firebasestorage.app',
    iosBundleId: 'com.example.movieCollectionApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCtvYEbe_lJxPQE0E5_yXAjNmmwqYCnkxk',
    appId: '1:249286272069:web:690e6e598ec3d22ad3af2c',
    messagingSenderId: '249286272069',
    projectId: 'movie-collection-app-cbe7f',
    authDomain: 'movie-collection-app-cbe7f.firebaseapp.com',
    storageBucket: 'movie-collection-app-cbe7f.firebasestorage.app',
  );
}
