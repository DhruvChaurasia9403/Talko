// File: Pages/Auth/AuthPage.dart

import 'dart:ui';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/AuthController.dart';
import 'package:chatting/Pages/Welcome/WelcomeHeading.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Authpage extends StatefulWidget {
  const Authpage({super.key});

  @override
  State<Authpage> createState() => _AuthpageState();
}

class _AuthpageState extends State<Authpage> {
  final TextEditingController phoneController = TextEditingController();
  final AuthController authController = Get.put(AuthController());

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
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient/Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AssetsImage.aiEarth), // Reusing your cool asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Deep Blur Overlay for OLED aesthetic
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
                  const welcomeHeading(),
                  const SizedBox(height: 50),
                  Text(
                    "Enter your phone number",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We will send you a confirmation code",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white54),
                  ),
                  const SizedBox(height: 40),

                  // World-Class Phone Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        // Country Picker Dropdown
                        InkWell(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              countryListTheme: CountryListThemeData(
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                textStyle: const TextStyle(color: Colors.white),
                                searchTextStyle: const TextStyle(color: Colors.white),
                                bottomSheetHeight: 500,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              onSelect: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Text(
                              "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        Container(width: 1, height: 30, color: Colors.white24), // Divider
                        // Number Input
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 18, letterSpacing: 2, color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "99999 99999",
                              hintStyle: TextStyle(color: Colors.white24, letterSpacing: 2),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  Obx(() => authController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: () {
                      String phone = phoneController.text.trim();
                      if (phone.isNotEmpty) {
                        String fullNumber = "+${selectedCountry.phoneCode}$phone";
                        authController.sendOtp(fullNumber);
                      } else {
                        Get.snackbar("Invalid", "Please enter a valid phone number");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      "Continue",
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