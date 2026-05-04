import 'package:chatting/Controller/AuthController.dart';
import '../../Controller/ThemeController.dart';
import 'package:chatting/Widgets/PremiumSurface.dart';
import 'package:chatting/Widgets/AmbientBackground.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController otpController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      child: Stack(
        children: [
          // Custom Back Button inside the SafeArea
          Positioned(
            top: 10,
            left: 10,
            child: Obx(() => IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: themeController.text),
              onPressed: () => Get.back(),
            )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() => Icon(Icons.shield_rounded, size: 80, color: themeController.primary)),
                const SizedBox(height: 30),
                Obx(() => Text(
                  "Verification Code",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeController.text
                  ),
                )),
                const SizedBox(height: 10),
                Obx(() => Text(
                  "Enter the 6-digit code sent to\n${authController.enteredPhoneNumber}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: themeController.subText,
                      height: 1.5
                  ),
                )),
                const SizedBox(height: 40),

                // Ambient OTP Input
                PremiumSurface(
                  borderRadius: 24,
                  child: Obx(() => TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: TextStyle(fontSize: 32, letterSpacing: 15, fontWeight: FontWeight.bold, color: themeController.text),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "------",
                      hintStyle: TextStyle(color: themeController.subText.withAlpha(100), letterSpacing: 15),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(vertical: 24),
                    ),
                  )),
                ),
                const SizedBox(height: 40),

                Obx(() => authController.isLoading.value
                    ? Center(child: CircularProgressIndicator(color: themeController.primary))
                    : ElevatedButton(
                  onPressed: () {
                    if (otpController.text.length == 6) {
                      authController.verifyOtp(otpController.text);
                    } else {
                      Get.snackbar("Invalid", "Please enter a 6-digit code.",
                          backgroundColor: Colors.redAccent.withAlpha(200), colorText: Colors.white);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeController.primary,
                    foregroundColor: Colors.white,
                    elevation: themeController.isGlass ? 0 : 4,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    "Verify & Proceed",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}