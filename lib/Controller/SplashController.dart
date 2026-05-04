// File: Controller/SplashController.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    splashHandle();
  }

  Future<void> splashHandle() async {
    // ONLY wait for the animation, do NOT request permissions here.
    await Future.delayed(const Duration(seconds: 2));

    if (auth.currentUser == null) {
      Get.offAllNamed('/authPage');
    } else {
      Get.offAllNamed('/homePage');
    }
  }
}