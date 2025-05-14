import 'package:chatting/Config/PagePath.dart';
import 'package:chatting/Config/Themes.dart';
import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Controller/NotificationController.dart';
import 'package:chatting/Pages/Splash/SplashPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize NotificationController
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
      home: const Splashpage(),
    );
  }
}