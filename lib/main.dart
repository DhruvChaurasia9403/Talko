// File: main.dart

import 'package:chatting/Config/AppLocalization.dart';
import 'package:chatting/Config/PagePath.dart';
import 'package:chatting/Config/Themes.dart';
import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Controller/NotificationController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- ADDED for instant auth check
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'Controller/ThemeController.dart';
import 'Model/UserModel.dart';
import 'Pages/Chat/chatPage.dart';
import 'Pages/Auth/AuthPage.dart'; // <-- ADDED to route here if not logged in
import 'Pages/Home/HomePage.dart'; // <-- ADDED to route here if logged in

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  // The native splash screen stays up automatically while these await tasks finish!
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
  } catch (e) {
    debugPrint("AppCheck Error: $e");
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final NotificationController notificationController = NotificationController(flutterLocalNotificationsPlugin);

  // Initialize Core Controllers
  Get.put(ThemeController(), permanent: true);
  Get.put(notificationController);
  Get.put(ChatController(notificationController));

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    if (message.data.containsKey('senderId')) {
      String senderId = message.data['senderId'];
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(senderId).get();

      if (userDoc.exists) {
        UserModel senderUser = UserModel.fromJson(userDoc.data()!);
        Get.toNamed('/homePage');
        Get.to(() => chatPage(userModel: senderUser));
      }
    }
  });

  // --- INSTANT ROUTING LOGIC ---
  // The moment Firebase is ready, we check the auth state.
  Widget initialPage = FirebaseAuth.instance.currentUser == null
      ? const Authpage()
      : const HomePage();

  // Pass the chosen page into MyApp
  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget initialPage; // <-- Accept the initial page

  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      title: 'Sampark',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeController.themeMode.value,
      translations: AppLocalization(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      getPages: pagePath,
      home: initialPage, // <-- Use the instantly calculated page instead of Splashpage
    ));
  }
}