import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationController with WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool _isAppInForeground = true;

  NotificationController(this.flutterLocalNotificationsPlugin) {
    WidgetsBinding.instance.addObserver(this);
    tz.initializeTimeZones();
    _initializeNotifications();
  }

  /// Track app foreground/background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = state == AppLifecycleState.resumed;
  }

  /// Initialize plugin and request permissions
  Future<void> _initializeNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Request permissions
    if (Platform.isAndroid) {
      await Permission.notification.request();
      await Permission.scheduleExactAlarm.request();
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Open exact alarm settings (Android 12+)
  Future<void> openExactAlarmSettings() async {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    }
  }

  /// Schedule a notification after `seconds`
  Future<void> scheduleNotification(int seconds) async {
    if (!await Permission.notification.isGranted) {
      await _initializeNotifications();
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    final iosDetails = DarwinNotificationDetails();

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // unique ID
      'Reminder Alert',
      'Your scheduled notification is here!',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint("✅ Notification scheduled successfully in $seconds seconds.");
  }

  /// Show instant notification if app is not in foreground
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    if (!_isAppInForeground) {
      final androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        channelDescription: 'Channel for reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        color: const Color(0xff0A0A0A),
      );

      final iosDetails = DarwinNotificationDetails();

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000), // unique ID
        title,
        body,
        platformDetails,
      );

      debugPrint("✅ Instant notification displayed!");
    } else {
      debugPrint("ℹ️ App is in foreground, no notification displayed.");
    }
  }

  /// Call this manually when needed
  void disposeController() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
