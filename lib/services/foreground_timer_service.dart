import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:skill_timer/widgets/common_ui_elements.dart';

class ForegroundTimerService {
  static const int serviceId =
      1234567890; // Unique ID for the foreground service
  static const String channelId = 'skill_timer_foreground';
  static const String channelName = 'Skill Timer Foreground Service';

  static Future<void> requestPermissions() async {
    final notificationPermisson =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermisson != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: channelId,
        channelName: channelName,
        channelDescription: 'Foreground service for Skill Timer',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  static Future<void> start({
    required String skillName,
    required Duration elapsed,
  }) async {
    if (!Platform.isAndroid) {
      return;
    }

    await requestPermissions();

    final text = _notificationText(skillName, elapsed);

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Skill Timer',
        notificationText: text,
      );
    } else {
      await FlutterForegroundTask.startService(
        serviceId: serviceId,
        notificationTitle: 'Skill Timer',
        notificationText: text,
        notificationIcon: null,
        notificationInitialRoute: '/',
      );
    }
  }

  static Future<void> update({
    required String skillName,
    required Duration elapsed,
  }) async {
    if (!Platform.isAndroid) {
      return;
    }

    final text = _notificationText(skillName, elapsed);

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Skill Timer',
        notificationText: text,
      );
    }
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) {
      return;
    }

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  static String _notificationText(String skillName, Duration elapsed) {
    final elapsedStr = TimeFormatter.formatWithSeconds(elapsed);
    return 'Skill: $skillName\nElapsed Time: $elapsedStr';
  }
}
