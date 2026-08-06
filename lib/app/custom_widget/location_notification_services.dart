import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = "chat_messages_channel";
  static const String channelName = "Chat Messages";

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    channelId,
    channelName,
    description: "Notifications for chat messages",
    importance: Importance.max,
  );

Future<void> initialize() async {
  const android = AndroidInitializationSettings("@mipmap/ic_launcher");

  const settings = InitializationSettings(
    android: android,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: settings,
  );

  // ✅ FIX: () को generic के ठीक बाद, बिना line break confusion के लगाएं
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  await androidImplementation?.createNotificationChannel(_channel);

  log("✅ Notification channel created: $channelId");
}
  Future<void> show({
    required String title,
    required String body,
  }) async {
    final android = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: android),
    );
  }
}