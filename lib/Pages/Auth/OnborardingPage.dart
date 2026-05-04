// File: Pages/Auth/OnboardingPage.dart

import 'dart:ui';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/AuthController.dart';
import 'package:chatting/Controller/ImagePickerController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final AuthController authController = Get.find<AuthController>();
  final ImagePickerController imagePickerController = Get.put(ImagePickerController());

  // Form State
  int _currentPage = 0;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  RxString profileImageUrl = "".obs;

  void _nextPage() {
    if (_currentPage == 0 && nameController.text.trim().isEmpty) {
      Get.snackbar("Hold up", "Please enter your name to continue.");
      return;
    }
    if (_currentPage < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _submitProfile();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _submitProfile() {
    String finalImage = profileImageUrl.value.isEmpty ? AssetsImage.defaultPic : profileImageUrl.value;
    String finalAbout = aboutController.text.trim().isEmpty ? "Available" : aboutController.text.trim();

    authController.finalizeNewUser(
      nameController.text.trim(),
      finalAbout,
      finalImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(AssetsImage.aiEarth), fit: BoxFit.cover),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
            child: Container(color: Colors.black.withOpacity(0.85)),
          ),
          SafeArea(
            child: Column(
              children: [
                // Progress Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentPage >= index ? Theme.of(context).colorScheme.primary : Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Disable swipe, force button use
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildProfileSetup(),
                      _buildTnc(),
                      _buildReview(),
                    ],
                  ),
                ),

                // Bottom Navigation Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: _prevPage,
                          child: const Text("Back", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        )
                      else
                        const SizedBox(width: 60), // Spacer

                      Obx(() => authController.isLoading.value
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: Text(
                          _currentPage == 2 ? "Launch SAMPARK" : "Next",
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 1: PROFILE ---
  Widget _buildProfileSetup() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Setup Profile", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("How should people recognize you?", style: TextStyle(color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 40),

          GestureDetector(
            onTap: () async {
              String? url = await imagePickerController.pickAndUploadImage();
              if (url != null) profileImageUrl.value = url;
            },
            child: Obx(() => Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 20)],
              ),
              child: imagePickerController.isUploading.value
                  ? const Center(child: CircularProgressIndicator())
                  : profileImageUrl.value.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(60), child: Image.network(profileImageUrl.value, fit: BoxFit.cover))
                  : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white54, size: 30),
                  SizedBox(height: 4),
                  Text("Add Photo", style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            )),
          ),
          const SizedBox(height: 40),

          _buildGlassInput("Display Name", Icons.person, nameController),
          const SizedBox(height: 16),
          _buildGlassInput("About (Optional)", Icons.info_outline, aboutController),
        ],
      ),
    );
  }

  // --- STEP 2: T&C ---
  Widget _buildTnc() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Legal Terms", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Please review our terms of service.", style: TextStyle(color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: const SingleChildScrollView(
                child: Text(
                  """Welcome to SAMPARK. 

By using our service, you agree to these terms. Please read them carefully.

1. Privacy & Data
SAMPARK is built on trust. We securely store your profile and chat metadata. You agree to allow us to sync your local contacts to find friends already on the platform.

2. User Conduct
You agree not to misuse our services. Do not use SAMPARK for illegal activities, harassment, or distribution of malicious software.

3. Artificial Intelligence (V.O.I.D.)
Interactions with our AI assistant, V.O.I.D., may be processed to improve intelligence accuracy. Avoid sharing sensitive personal information with the AI.

4. Termination
We reserve the right to suspend or terminate your account if you violate these terms.

By clicking "Next", you acknowledge that you have read and understood these terms.""",
                  style: TextStyle(color: Colors.white70, height: 1.6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- STEP 3: REVIEW ---
  Widget _buildReview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.greenAccent),
          const SizedBox(height: 20),
          Text("All Set!", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Review your details before launching.", style: TextStyle(color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Obx(() => CircleAvatar(
                  radius: 35,
                  backgroundImage: profileImageUrl.value.isNotEmpty ? NetworkImage(profileImageUrl.value) : const NetworkImage(AssetsImage.defaultPic),
                )),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nameController.text.trim(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(authController.enteredPhoneNumber, style: const TextStyle(fontSize: 14, color: Colors.white54)),
                      const SizedBox(height: 4),
                      Text(aboutController.text.trim().isEmpty ? "Available" : aboutController.text.trim(), style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInput(String hint, IconData icon, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: Icon(icon, color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}