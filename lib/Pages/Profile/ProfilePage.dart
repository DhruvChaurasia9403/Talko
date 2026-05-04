import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ImagePickerController.dart';
import 'package:chatting/Controller/ProfileController.dart';
import '../../Controller/ThemeController.dart';
import 'package:chatting/Widgets/PremiumSurface.dart';
import 'package:chatting/Widgets/AmbientBackground.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final ImagePickerController imagePickerController = Get.put(ImagePickerController());
    final ThemeController themeController = Get.find<ThemeController>();

    final RxBool isEdit = false.obs;
    final RxString imagePath = "".obs;
    final RxBool isLoading = false.obs;

    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let ambient orbs shine through
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Obx(() => Text(
              isEdit.value ? "Edit Profile" : "My Profile",
              style: TextStyle(color: themeController.text, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)
          )),
          leading: Obx(() => IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: themeController.text),
            onPressed: () => Get.offAllNamed('/homePage'),
          )),
          actions: [
            Obx(() => isEdit.value
                ? const SizedBox.shrink()
                : IconButton(
              icon: Icon(Icons.edit_note, color: themeController.primary),
              onPressed: () => isEdit.value = true,
            )
            )
          ],
        ),
        body: SafeArea(
          child: Obx(() {
            final currentUser = profileController.currentUser.value;
            final TextEditingController name = TextEditingController(text: currentUser.name ?? "");
            final TextEditingController about = TextEditingController(text: currentUser.about ?? "");

            if (imagePath.value.isEmpty && currentUser.profileImage != null) {
              imagePath.value = currentUser.profileImage!;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // --- AVATAR & IDENTITY SECTION ---
                  GestureDetector(
                    onTap: () async {
                      if (isEdit.value) {
                        String? url = await imagePickerController.pickAndUploadImage();
                        if (url != null) imagePath.value = url;
                      }
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 150, width: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: themeController.primary.withAlpha(150), width: 4),
                            boxShadow: themeController.isGlass ? [] : [
                              BoxShadow(color: themeController.primary.withAlpha(80), blurRadius: 40, spreadRadius: 2)
                            ],
                          ),
                          child: imagePickerController.isUploading.value
                              ? Center(child: CircularProgressIndicator(color: themeController.primary))
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(imagePath.value.isNotEmpty ? imagePath.value : AssetsImage.defaultPic, fit: BoxFit.cover),
                          ),
                        ),
                        if (isEdit.value)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: themeController.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: themeController.bg, width: 4)
                            ),
                            child: Icon(Icons.camera_alt, color: themeController.isDark ? Colors.black : Colors.white, size: 22),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Identity Text (Only shows when NOT editing)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: isEdit.value ? const SizedBox.shrink() : Column(
                      children: [
                        Text(
                            currentUser.name ?? "Unknown User",
                            style: TextStyle(color: themeController.text, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1.2)
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.greenAccent.withAlpha(100), blurRadius: 6)]),
                            ),
                            const SizedBox(width: 8),
                            Text("Online", style: TextStyle(color: themeController.subText, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.1)),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // --- SECTION 1: PERSONAL INFORMATION ---
                  _buildSectionHeader("Personal Information", Icons.badge_outlined, themeController),
                  const SizedBox(height: 12),
                  PremiumSurface(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      children: [
                        _buildSettingsField("Display Name", Icons.person, name, isEdit.value, themeController),
                        Divider(color: themeController.subText.withAlpha(30), height: 1, indent: 50),
                        _buildSettingsField("Bio / About", Icons.format_quote_rounded, about, isEdit.value, themeController),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- SECTION 2: ACCOUNT DETAILS ---
                  _buildSectionHeader("Account Details", Icons.admin_panel_settings_outlined, themeController),
                  const SizedBox(height: 12),
                  PremiumSurface(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      children: [
                        _buildReadOnlyRow("Phone Number", Icons.phone_android, currentUser.phoneNumber ?? "Not set", themeController),
                        Divider(color: themeController.subText.withAlpha(30), height: 1, indent: 50),
                        _buildReadOnlyRow("Email Address", Icons.email_outlined, currentUser.email?.isNotEmpty == true ? currentUser.email! : "Not set", themeController),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- SECTION 3: APP APPEARANCE ---
                  _buildSectionHeader("Ambient Architecture", Icons.palette_outlined, themeController),
                  const SizedBox(height: 12),
                  PremiumSurface(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildToggleRow("Dark Mode", "Deep OLED black environment", themeController.isDark, (val) => themeController.toggleTheme(), themeController),
                        Divider(color: themeController.subText.withAlpha(30), height: 20),
                        _buildToggleRow("Glassmorphism", "Frosted glass rendering engine", themeController.isGlass, (val) => themeController.toggleDesignStyle(), themeController),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- ACTION BUTTONS (Save / Logout) ---
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: isEdit.value
                        ? (isLoading.value
                        ? Center(child: CircularProgressIndicator(color: themeController.primary))
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          isLoading.value = true;
                          await profileController.updateUserProfile(
                            imageUrl: imagePath.value, name: name.text.trim(),
                            about: about.text.trim(), phoneNumber: currentUser.phoneNumber ?? "",
                          );
                          isLoading.value = false;
                          isEdit.value = false;
                        },
                        icon: Icon(Icons.check_circle_outline, color: themeController.isDark ? Colors.black : Colors.white),
                        label: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeController.primary,
                          foregroundColor: themeController.isDark ? Colors.black : Colors.white,
                          elevation: themeController.isGlass ? 0 : 5,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ))
                        : SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () async {
                          await profileController.signOut();
                          Get.offAllNamed('/authPage');
                        },
                        icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
                        label: const Text("Disconnect Account", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent.withAlpha(20),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.redAccent.withAlpha(50))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // Helper for Section Titles
  Widget _buildSectionHeader(String title, IconData icon, ThemeController themeController) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
          Icon(icon, color: themeController.primary, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: themeController.primary, fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 14)),
        ],
      ),
    );
  }

  // Helper for Editable Form Fields inside Groups
  Widget _buildSettingsField(String label, IconData icon, TextEditingController controller, bool isEdit, ThemeController themeController) {
    return TextField(
      controller: controller,
      enabled: isEdit,
      style: TextStyle(color: isEdit ? themeController.text : themeController.subText, fontSize: 16, fontWeight: isEdit ? FontWeight.w600 : FontWeight.normal),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: themeController.subText, fontSize: 14),
        prefixIcon: Icon(icon, color: isEdit ? themeController.primary : themeController.subText.withAlpha(150)),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        fillColor: Colors.transparent,
      ),
    );
  }

  // Helper for Non-Editable Rows (Phone/Email)
  Widget _buildReadOnlyRow(String label, IconData icon, String value, ThemeController themeController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: themeController.subText.withAlpha(150)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: themeController.subText, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: themeController.text, fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper for Theme Toggles
  Widget _buildToggleRow(String title, String subtitle, bool value, Function(bool) onChanged, ThemeController themeController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: themeController.text, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: themeController.subText, fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: themeController.primary,
          inactiveTrackColor: themeController.subText.withAlpha(50),
        ),
      ],
    );
  }
}