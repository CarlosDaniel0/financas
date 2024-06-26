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
    apiKey: 'AIzaSyDSIuSY3JmORFPy4wJ7wXjNVW4BIdoEBTA',
    appId: '1:589016471150:web:80c1ed65394610c1f9787f',
    messagingSenderId: '589016471150',
    projectId: 'financas-422cb',
    authDomain: 'financas-422cb.firebaseapp.com',
    storageBucket: 'financas-422cb.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBm7rxxjtKdT3yna-x5NFroL7iiYIQLMxI',
    appId: '1:589016471150:android:f0b171a783444b39f9787f',
    messagingSenderId: '589016471150',
    projectId: 'financas-422cb',
    storageBucket: 'financas-422cb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWdEGAERKFO01pisaNJjknCdaTnDUPpzk',
    appId: '1:589016471150:ios:ca006ac573f417a1f9787f',
    messagingSenderId: '589016471150',
    projectId: 'financas-422cb',
    storageBucket: 'financas-422cb.appspot.com',
    androidClientId: '589016471150-0b3odat8pvf542s72up7apbh30f92lal.apps.googleusercontent.com',
    iosClientId: '589016471150-33v275jnu4mmpm307ui0m7lhmj7oh5gh.apps.googleusercontent.com',
    iosBundleId: 'br.app.financas',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWdEGAERKFO01pisaNJjknCdaTnDUPpzk',
    appId: '1:589016471150:ios:41460b486881d18df9787f',
    messagingSenderId: '589016471150',
    projectId: 'financas-422cb',
    storageBucket: 'financas-422cb.appspot.com',
    androidClientId: '589016471150-0b3odat8pvf542s72up7apbh30f92lal.apps.googleusercontent.com',
    iosClientId: '589016471150-r2kp1pctdc8bfj3v3ik0m4cmcj9gqn2b.apps.googleusercontent.com',
    iosBundleId: 'br.app.financas.RunnerTests',
  );
}
