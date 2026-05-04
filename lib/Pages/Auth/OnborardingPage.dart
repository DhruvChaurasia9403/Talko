import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/AuthController.dart';
import 'package:chatting/Controller/ImagePickerController.dart';
import 'package:chatting/Widgets/AmbientBackground.dart';
import 'package:chatting/Widgets/PremiumSurface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/ThemeController.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final AuthController authController = Get.find<AuthController>();
  final ImagePickerController imagePickerController = Get.put(ImagePickerController());
  final ThemeController themeController = Get.find<ThemeController>();

  int _currentPage = 0;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  RxString profileImageUrl = "".obs;

  void _nextPage() {
    if (_currentPage == 0 && nameController.text.trim().isEmpty) {
      Get.snackbar("Hold up", "Please enter your name to continue.", backgroundColor: Colors.redAccent.withAlpha(200), colorText: Colors.white);
      return;
    }
    if (_currentPage < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuart);
    } else {
      _submitProfile();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuart);
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
    return AmbientBackground(
      child: Column(
        children: [
          // Progress Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage >= index ? themeController.primary : themeController.subText.withAlpha(50),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )),
                );
              }),
            ),
          ),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildProfileSetup(),
                _buildTnc(),
                _buildReview(),
              ],
            ),
          ),

          // Bottom Navigation Bar
          Obx(() => PremiumSurface(
            borderRadius: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: _prevPage,
                    child: Text("Back", style: TextStyle(color: themeController.subText, fontSize: 16)),
                  )
                else
                  const SizedBox(width: 60),

                authController.isLoading.value
                    ? CircularProgressIndicator(color: themeController.primary)
                    : ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeController.primary,
                    foregroundColor: Colors.white,
                    elevation: themeController.isGlass ? 0 : 4,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    _currentPage == 2 ? "Launch SAMPARK" : "Next",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
                  ),
                ),
              ],
            ),
          )),
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
          Obx(() => Text("Setup Profile", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: themeController.text))),
          const SizedBox(height: 10),
          Obx(() => Text("How should people recognize you?", style: TextStyle(color: themeController.subText))),
          const SizedBox(height: 40),

          GestureDetector(
            onTap: () async {
              String? url = await imagePickerController.pickAndUploadImage();
              if (url != null) profileImageUrl.value = url;
            },
            child: Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                color: themeController.surface,
                shape: BoxShape.circle,
                border: Border.all(color: themeController.primary.withAlpha(150), width: 2),
                boxShadow: themeController.isGlass ? [] : [
                  BoxShadow(color: themeController.primary.withAlpha(50), blurRadius: 20)
                ],
              ),
              child: imagePickerController.isUploading.value
                  ? Center(child: CircularProgressIndicator(color: themeController.primary))
                  : profileImageUrl.value.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(65), child: Image.network(profileImageUrl.value, fit: BoxFit.cover))
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: themeController.subText, size: 30),
                  const SizedBox(height: 4),
                  Text("Add Photo", style: TextStyle(color: themeController.subText, fontSize: 12)),
                ],
              ),
            )),
          ),
          const SizedBox(height: 40),

          _buildPremiumInput("Display Name", Icons.person, nameController),
          const SizedBox(height: 16),
          _buildPremiumInput("About (Optional)", Icons.info_outline, aboutController),
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
          Obx(() => Text("Legal Terms", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: themeController.text))),
          const SizedBox(height: 10),
          Obx(() => Text("Please review our terms of service.", style: TextStyle(color: themeController.subText))),
          const SizedBox(height: 20),
          Expanded(
            child: PremiumSurface(
              padding: const EdgeInsets.all(24),
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
                  style: TextStyle(height: 1.6, fontSize: 14),
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
          Obx(() => Icon(Icons.check_circle_outline, size: 80, color: themeController.primary)),
          const SizedBox(height: 20),
          Obx(() => Text("All Set!", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: themeController.text))),
          const SizedBox(height: 10),
          Obx(() => Text("Review your details before launching.", style: TextStyle(color: themeController.subText))),
          const SizedBox(height: 40),

          PremiumSurface(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Obx(() => CircleAvatar(
                  radius: 35,
                  backgroundImage: profileImageUrl.value.isNotEmpty ? NetworkImage(profileImageUrl.value) : const NetworkImage(AssetsImage.defaultPic),
                )),
                const SizedBox(width: 20),
                Expanded(
                  child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nameController.text.trim(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeController.text)),
                      const SizedBox(height: 4),
                      Text(authController.enteredPhoneNumber, style: TextStyle(fontSize: 14, color: themeController.subText)),
                      const SizedBox(height: 4),
                      Text(aboutController.text.trim().isEmpty ? "Available" : aboutController.text.trim(), style: TextStyle(fontSize: 14, color: themeController.primary)),
                    ],
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumInput(String hint, IconData icon, TextEditingController controller) {
    return PremiumSurface(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Obx(() => TextField(
        controller: controller,
        style: TextStyle(color: themeController.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: themeController.subText.withAlpha(125)),
          prefixIcon: Icon(icon, color: themeController.subText),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      )),
    );
  }
}