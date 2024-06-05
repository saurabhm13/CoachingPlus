import 'dart:ffi';

import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseBackgroundMessaging(RemoteMessage message) async {
  if (message.notification != null) {
    print("Message");
  }
}

class FirebaseApi {

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _firebaseMessaging.requestPermission();

    final token = await _firebaseMessaging.getToken();
    print("Token: $token");
    _firebaseMessaging.subscribeToTopic("topic");
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessaging);
  }
}
