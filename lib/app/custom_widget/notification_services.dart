import 'dart:developer';

import 'package:dating_app/app/custom_widget/location_notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await requestPermission();
    await LocalNotificationService.instance.initialize();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    listenForeground();
    listenNotificationClick();
    listenTokenRefresh();
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      provisional: false,
    );

    log("Permission : ${settings.authorizationStatus}");
  }

  // 🔥 NEW: Public getter — other parts of the app (like profile creation)
  // can call this to get the current FCM token without touching
  // FirebaseMessaging directly.
  Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      print("📲 FCM Token fetched: $token");
      return token;
    } catch (e) {
      print("❌ Get FCM Token Error: $e");
      return null;
    }
  }

  Future<void> saveFCMToken() async {
    try {
      final token = await getFCMToken();

      if (token == null || token.isEmpty) {
        print('⚠️ FCM token is null — skipping save');
        return;
      }

      print("FCM Token: $token");

      // TODO: send this token to your backend so it can send push notifications

      _messaging.onTokenRefresh.listen((newToken) async {
        print('🔄 FCM token refreshed: $newToken');
        // TODO: update backend with newToken
      });
    } catch (e) {
      print("Save FCM Token Error: $e");
    }
  }

  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) {
      log("New Token : $token");

      /// Update backend
    });
  }

  void listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;
      LocalNotificationService.instance.show(
        title: notification.title ?? "",
        body: notification.body ?? "",
      );
    });
  }

  void listenNotificationClick() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log("Notification clicked");
      _handleNavigation(message);
    });

    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleNavigation(message);
      }
    });
  }

  void _handleNavigation(RemoteMessage message) {
    final type = message.data["type"];
    switch (type) {
      case "chat":
        /// Open Chat Screen
        break;
      case "interest":
        /// Open Interest Screen
        break;
      case "accepted":
        /// Open Accepted Interest
        break;
      default:
    }
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Background Notification");
}