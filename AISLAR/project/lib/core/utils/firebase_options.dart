import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: '',
      appId: '',
      messagingSenderId: '',
      projectId: 'aislar-connect',
      storageBucket: 'aislar-connect.appspot.com',
    );
  }
}
