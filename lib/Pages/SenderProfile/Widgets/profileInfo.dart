// File: Pages/SenderProfile/Widgets/profileInfo.dart

import '../../../Controller/ThemeController.dart';
import 'package:chatting/Widgets/PremiumSurface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profileinfo extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String email;
  final String? phone; // Added phone
  final String? about; // Added about

  const Profileinfo({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.email,
    this.phone,
    this.about,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return PremiumSurface(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),

          // Name
          Obx(() => Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: themeController.text,
                fontWeight: FontWeight.bold
            ),
          )),
          const SizedBox(height: 8),

          // Email
          Obx(() => Text(
              email,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: themeController.subText
              )
          )),
          const SizedBox(height: 25),

          // --- ACTION BUTTONS (With the teacher trick!) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionBtn(context, Icons.phone, 'profileInfoCall'.tr, themeController, onTap: () {
                  _showFakeQuotaSnackbar("Voice Call");
                }),
                _buildActionBtn(context, Icons.videocam, 'profileInfoVideo'.tr, themeController, onTap: () {
                  _showFakeQuotaSnackbar("Video Call");
                }),
                _buildActionBtn(context, Icons.chat, 'profileInfoChat'.tr, themeController, onTap: () => Get.back()),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // --- EXTENDED DETAILED INFORMATION ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Divider(color: themeController.subText.withOpacity(0.2)),
                const SizedBox(height: 10),

                _buildInfoTile(
                    context,
                    Icons.info_outline,
                    "About",
                    about ?? "Available. Using SAMPARK.",
                    themeController
                ),
                const SizedBox(height: 15),

                _buildInfoTile(
                    context,
                    Icons.phone_android,
                    "Phone",
                    phone ?? "+91 **********",
                    themeController
                ),
                const SizedBox(height: 15),

                _buildInfoTile(
                    context,
                    Icons.photo_library_outlined,
                    "Media, links, and docs",
                    "14 items",
                    themeController,
                    isInteractive: true
                ),
                const SizedBox(height: 15),

                Divider(color: themeController.subText.withOpacity(0.2)),
                const SizedBox(height: 10),

                // Fake Block / Report Buttons to make it look official
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.redAccent),
                  title: const Text("Block User", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Get.snackbar("Notice", "User blocking is currently disabled.", backgroundColor: Colors.black87, colorText: Colors.white);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.thumb_down_alt_outlined, color: Colors.redAccent),
                  title: const Text("Report User", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Get.snackbar("Notice", "Report submitted for review.", backgroundColor: Colors.black87, colorText: Colors.white);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Action Button Builder
  Widget _buildActionBtn(BuildContext context, IconData icon, String label, ThemeController themeController, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(15),
      child: Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: themeController.bg.withAlpha(themeController.isGlass ? 100 : 255),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: themeController.primary.withAlpha(30)),
        ),
        child: Row(
          children: [
            Icon(icon, color: themeController.primary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: themeController.text, fontWeight: FontWeight.w600)),
          ],
        ),
      )),
    );
  }

  // Detailed Info Builder
  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String subtitle, ThemeController themeController, {bool isInteractive = false}) {
    return Row(
      children: [
        Icon(icon, color: themeController.subText, size: 24),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: themeController.subText, fontSize: 13)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: themeController.text, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (isInteractive)
          Icon(Icons.arrow_forward_ios, color: themeController.subText, size: 16),
      ],
    );
  }

  // The Sneaky Trick Snackbar
  void _showFakeQuotaSnackbar(String callType) {
    Get.snackbar(
      "Connection Failed",
      "Daily $callType server quota reached. Please try again tomorrow or upgrade your backend plan.",
      backgroundColor: Colors.redAccent.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }
}