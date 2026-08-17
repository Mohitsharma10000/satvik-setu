import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<String?> getFcmToken() async {
    try {
      String? token = await _messaging.getToken();
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  void listenToForegroundMessages(Function(RemoteMessage) onMessage) {
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        onMessage(message);
      });
    } catch (e) {
      debugPrint('Error listening to foreground messages: $e');
    }
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    await firebaseMessagingBackgroundHandler(message);
  }
}
