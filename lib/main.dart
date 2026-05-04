import 'package:chatting/Config/AppLocalization.dart';
import 'package:chatting/Config/PagePath.dart';
import 'package:chatting/Config/Themes.dart';
import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Controller/NotificationController.dart';
import 'package:chatting/Pages/Splash/SplashPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'Model/UserModel.dart';
import 'Pages/Chat/chatPage.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
  } catch (e) {
    print(e);
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final NotificationController notificationController = NotificationController(flutterLocalNotificationsPlugin);

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