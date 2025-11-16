import 'package:chatting/Config/AppLocalization.dart';
import 'package:chatting/Config/PagePath.dart';
import 'package:chatting/Config/Themes.dart';
import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Controller/NotificationController.dart';
import 'package:chatting/Pages/Splash/SplashPage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // <-- ADD THIS
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// --- ADD THIS FUNCTION ---
// This *must* be a top-level function (not inside any class)
// This handles notifications when the app is TERMINATED (fully closed)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background,
  // make sure you call initializeApp first
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
// --- END OF NEW FUNCTION ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    // Use the debug provider for testing
    androidProvider: AndroidProvider.debug,
  );

  // --- ADD THIS LINE ---
  // This sets the handler for background/terminated messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // ---------------------

  // Initialize FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize NotificationController (this will now create our channel)
  final NotificationController notificationController =
  NotificationController(flutterLocalNotificationsPlugin);

  // Register NotificationController globally
  Get.put(notificationController);

  // Register ChatController globally and pass NotificationController
  Get.put(ChatController(notificationController));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sampark',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      getPages: pagePath,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,

      translations: AppLocalization(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),

      home: const Splashpage(),
    );
  }
}