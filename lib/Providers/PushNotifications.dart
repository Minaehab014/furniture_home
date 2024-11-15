import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotifications {
  static final _firebasMessaging = FirebaseMessaging.instance;

  static Future init() async {
    await _firebasMessaging.requestPermission();
    final token = _firebasMessaging.getToken();
    print("the token ${token}");
  }
}
