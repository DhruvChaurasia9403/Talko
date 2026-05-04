import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/AuthController.dart';
import 'package:chatting/Pages/Welcome/WelcomeHeading.dart';
import 'package:chatting/Widgets/PremiumSurface.dart';
import 'package:chatting/Widgets/AmbientBackground.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/ThemeController.dart';

class Authpage extends StatefulWidget {
  const Authpage({super.key});

  @override
  State<Authpage> createState() => _AuthpageState();
}

class _AuthpageState extends State<Authpage> {
  final TextEditingController phoneController = TextEditingController();
  final AuthController authController = Get.put(AuthController());
  final ThemeController themeController = Get.find<ThemeController>();

  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "India",
    displayName: "India",
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );

  @override
  Widget build(BuildContext context) {
    // The AmbientBackground acts as our Scaffold now
    return AmbientBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const welcomeHeading(),
            const SizedBox(height: 50),
            Obx(() => Text(
              "Enter your phone number",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: themeController.text,
              ),
            )),
            const SizedBox(height: 10),
            Obx(() => Text(
              "We will send you a confirmation code",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: themeController.subText,
              ),
            )),
            const SizedBox(height: 40),

            // Ambient Premium Phone Input
            PremiumSurface(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              borderRadius: 24,
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        countryListTheme: CountryListThemeData(
                          backgroundColor: themeController.bg,
                          textStyle: TextStyle(color: themeController.text),
                          searchTextStyle: TextStyle(color: themeController.text),
                          bottomSheetHeight: 500,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        onSelect: (value) => setState(() => selectedCountry = value),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Obx(() => Text(
                        "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeController.text
                        ),
                      )),
                    ),
                  ),
                  Obx(() => Container(width: 1, height: 30, color: themeController.subText.withAlpha(50))), // Divider
                  Expanded(
                    child: Obx(() => TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: 18, letterSpacing: 2, color: themeController.text),
                      decoration: InputDecoration(
                        hintText: "99999 99999",
                        hintStyle: TextStyle(color: themeController.subText.withAlpha(100), letterSpacing: 2),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Submit Button
            Obx(() => authController.isLoading.value
                ? Center(child: CircularProgressIndicator(color: themeController.primary))
                : ElevatedButton(
              onPressed: () {
                String phone = phoneController.text.trim();
                if (phone.isNotEmpty) {
                  authController.sendOtp("+${selectedCountry.phoneCode}$phone");
                } else {
                  Get.snackbar("Invalid", "Please enter a valid phone number",
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
                "Continue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
            )),
          ],
        ),
      ),
    );
  }
}