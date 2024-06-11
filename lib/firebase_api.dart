
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseBackgroundMessaging(RemoteMessage message) async {
  if (message.notification != null) {
    // print("Message");
  }
}

class FirebaseApi {

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _firebaseMessaging.requestPermission();

    _firebaseMessaging.subscribeToTopic("coachingplusapp");
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessaging);
  }

  Future<String?> getToken() async {
    final token = await _firebaseMessaging.getToken();
    // print(token);
    return token;
  }
}
