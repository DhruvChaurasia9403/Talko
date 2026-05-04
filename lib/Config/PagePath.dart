// File: Config/PagePath.dart

import 'package:chatting/AI/Features/Prompt/UI/create_prompt.dart';
import 'package:chatting/Pages/Auth/AuthPage.dart';
import 'package:chatting/Pages/Auth/OtpPage.dart';
import 'package:chatting/Pages/Contact/ContactPage.dart';
import 'package:chatting/Pages/Home/HomePage.dart';
import 'package:get/get.dart';

import '../Pages/Auth/OnborardingPage.dart';

var pagePath = [
  GetPage(name: "/authPage", page: () => const Authpage(), transition: Transition.fadeIn),
  GetPage(name: "/otpPage", page: () => const OtpPage(), transition: Transition.rightToLeft), // <-- NEW
  GetPage(name: "/onboardingPage", page: () => const OnboardingPage(), transition: Transition.fadeIn), // <-- NEW
  GetPage(name: "/homePage", page: () => const HomePage(), transition: Transition.fadeIn),
  GetPage(name: "/aiPage", page: () => const CreatePromptScreen(), transitionDuration: const Duration(milliseconds: 100)),
  GetPage(name: "/contactPage", page: () => const Contactpage(), transition: Transition.fadeIn)
];