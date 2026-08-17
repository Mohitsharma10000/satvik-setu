import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Generated with user provided Firebase configuration for project `service-60f49`.
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
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCuyt24lHsHrDDOF5K-3t18kCAkpU-r13w',
    appId: '1:400847298160:web:7123ab86f058e9173c5eb5',
    messagingSenderId: '400847298160',
    projectId: 'service-60f49',
    authDomain: 'service-60f49.firebaseapp.com',
    storageBucket: 'service-60f49.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCuyt24lHsHrDDOF5K-3t18kCAkpU-r13w',
    appId: '1:400847298160:android:7123ab86f058e9173c5eb5',
    messagingSenderId: '400847298160',
    projectId: 'service-60f49',
    storageBucket: 'service-60f49.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCuyt24lHsHrDDOF5K-3t18kCAkpU-r13w',
    appId: '1:400847298160:ios:7123ab86f058e9173c5eb5',
    messagingSenderId: '400847298160',
    projectId: 'service-60f49',
    storageBucket: 'service-60f49.firebasestorage.app',
    iosBundleId: 'com.service.SevaConnect',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCuyt24lHsHrDDOF5K-3t18kCAkpU-r13w',
    appId: '1:400847298160:ios:7123ab86f058e9173c5eb5',
    messagingSenderId: '400847298160',
    projectId: 'service-60f49',
    storageBucket: 'service-60f49.firebasestorage.app',
    iosBundleId: 'com.service.SevaConnect',
  );
}
