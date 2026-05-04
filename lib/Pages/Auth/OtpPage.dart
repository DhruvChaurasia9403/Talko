// File: Pages/Auth/OtpPage.dart

import 'dart:ui';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/AuthController.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(AssetsImage.aiEarth), fit: BoxFit.cover),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.message_rounded, size: 80, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 30),
                  Text(
                    "Verification Code",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Enter the 6-digit code sent to\n${authController.enteredPhoneNumber}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white54, height: 1.5),
                  ),
                  const SizedBox(height: 40),

                  // World-Class OTP Input
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(fontSize: 32, letterSpacing: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      decoration: const InputDecoration(
                        counterText: "",
                        hintText: "------",
                        hintStyle: TextStyle(color: Colors.white24, letterSpacing: 15),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  Obx(() => authController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: () {
                      if (otpController.text.length == 6) {
                        authController.verifyOtp(otpController.text);
                      } else {
                        Get.snackbar("Invalid", "Please enter a 6-digit code.");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      "Verify & Proceed",
                      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}