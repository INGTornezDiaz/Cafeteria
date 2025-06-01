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

  // Reemplaza estos valores con los de tu proyecto Firebase
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDBSfp41HGwNpXISV1d3iA86Lz-eAUjbbA',
    appId: '1:423268040909:web:d55ce9a027d15c8b986984',
    messagingSenderId: '423268040909',
    projectId: 'comedor-e3b71',
    authDomain: 'comedor-e3b71.firebaseapp.com',
    storageBucket: 'comedor-e3b71.appspot.com',
    databaseURL: 'https://comedor-e3b71-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDBSfp41HGwNpXISV1d3iA86Lz-eAUjbbA',
    appId: '1:423268040909:android:d55ce9a027d15c8b986984',
    messagingSenderId: '423268040909',
    projectId: 'comedor-e3b71',
    storageBucket: 'comedor-e3b71.appspot.com',
    databaseURL: 'https://comedor-e3b71-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBSfp41HGwNpXISV1d3iA86Lz-eAUjbbA',
    appId: '1:423268040909:ios:d55ce9a027d15c8b986984',
    messagingSenderId: '423268040909',
    projectId: 'comedor-e3b71',
    storageBucket: 'comedor-e3b71.appspot.com',
    databaseURL: 'https://comedor-e3b71-default-rtdb.firebaseio.com',
    iosClientId: '423268040909-ios-client-id',
    iosBundleId: 'com.example.flutterPlatillos',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDBSfp41HGwNpXISV1d3iA86Lz-eAUjbbA',
    appId: '1:423268040909:macos:d55ce9a027d15c8b986984',
    messagingSenderId: '423268040909',
    projectId: 'comedor-e3b71',
    storageBucket: 'comedor-e3b71.appspot.com',
    databaseURL: 'https://comedor-e3b71-default-rtdb.firebaseio.com',
    iosClientId: '423268040909-macos-client-id',
    iosBundleId: 'com.example.flutterPlatillos',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDBSfp41HGwNpXISV1d3iA86Lz-eAUjbbA',
    appId: '1:423268040909:windows:d55ce9a027d15c8b986984',
    messagingSenderId: '423268040909',
    projectId: 'comedor-e3b71',
    storageBucket: 'comedor-e3b71.appspot.com',
    databaseURL: 'https://comedor-e3b71-default-rtdb.firebaseio.com',
  );
}
