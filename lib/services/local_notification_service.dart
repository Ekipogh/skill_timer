import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<void>? _initialization;

  static Future<void> init() async {
    if (!Platform.isAndroid) {
      return;
    }

    final existingInitialization = _initialization;
    if (existingInitialization != null) {
      await existingInitialization;
      return;
    }

    final initialization = _initialize();
    _initialization = initialization;

    try {
      await initialization;
    } catch (_) {
      if (identical(_initialization, initialization)) {
        _initialization = null;
      }
      rethrow;
    }
  }

  static Future<void> _initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification(String title, String body) async {
    if (!Platform.isAndroid) {
      return;
    }

    await init();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'skill_timer_channel',
          'Skill Timer Notifications',
          channelDescription: 'Notifications for the Skill Timer app',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          sound: null, // Use default notification sound
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await LocalNotificationService.flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
