import 'package:chatting/Config/PagePath.dart';
import 'package:chatting/Config/Themes.dart';
import 'package:chatting/Pages/Splash/SplashPage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Cloudinary setup
  const String cloudName = "dgsxsujn9";
  const String apiKey = "298341531231328";
  const String apiSecret = "P8cYl99PCaAgDTvcJ7XKV6xwnLE";

  print("Cloudinary initialized for $cloudName");

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
