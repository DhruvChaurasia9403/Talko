import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationController(this.flutterLocalNotificationsPlugin) {
    tz.initializeTimeZones();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // --- This is the new, important part ---
    // Create the high-importance channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important chat notifications.', // description
      importance: Importance.high,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    // --- End of new part ---

    // Request permissions
    if (Platform.isAndroid) {
      await Permission.notification.request();
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// This function is now called by the FirebaseMessaging.onMessage
  /// listener in main.dart to show a notification *while the app is open*.
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'reminder_channel', // Make sure this channel ID is descriptive
      'Chat Messages',    // Channel Name
      channelDescription: 'Channel for chat notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      color: const Color(0xff0A0A0A),
    );

    final iosDetails = DarwinNotificationDetails(presentSound: true);

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Directly show the notification
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformDetails,
    );

    debugPrint("✅ Instant (foreground) notification displayed!");
  }

  // This function is for scheduling local reminders, NOT for chat.
  // It is fine to leave here for other features.
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
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'notificationTitle'.tr,
      'notificationBody'.tr,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint("✅ Notification scheduled successfully in $seconds seconds.");
  }
}