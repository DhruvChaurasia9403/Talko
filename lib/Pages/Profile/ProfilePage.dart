// File: Pages/Profile/ProfilePage.dart

import 'dart:ui';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ImagePickerController.dart';
import 'package:chatting/Controller/ProfileController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/DBController.dart';
import '../../Controller/LocalContactsController.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final ImagePickerController imagePickerController = Get.put(ImagePickerController());

    final RxBool isEdit = false.obs;
    final RxString imagePath = "".obs;
    final RxBool isLoading = false.obs;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.offAllNamed('/homePage'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              // 1. Sign out of Firebase
              await profileController.signOut();
              // 2. Safely route back to Auth (Do NOT delete controllers)
              Get.offAllNamed('/authPage');
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(AssetsImage.aiEarth), fit: BoxFit.cover),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
            child: Container(color: Colors.black.withOpacity(0.75)),
          ),

          SafeArea(
            child: Obx(() {
              final currentUser = profileController.currentUser.value;
              final TextEditingController name = TextEditingController(text: currentUser.name ?? "");
              final TextEditingController about = TextEditingController(text: currentUser.about ?? "");

              // Set initial image
              if (imagePath.value.isEmpty && currentUser.profileImage != null) {
                imagePath.value = currentUser.profileImage!;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // --- AVATAR SECTION ---
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
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                            child: imagePickerController.isUploading.value
                                ? const Center(child: CircularProgressIndicator())
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                imagePath.value.isNotEmpty ? imagePath.value : AssetsImage.defaultPic,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (isEdit.value)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.black, size: 24),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- DETAILS SECTION ---
                    _buildProfileField(context, "Display Name", Icons.person, name, isEdit.value),
                    const SizedBox(height: 20),
                    _buildProfileField(context, "About", Icons.info_outline, about, isEdit.value),
                    const SizedBox(height: 20),

                    // Non-editable Phone Number
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.white54),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Phone Number", style: TextStyle(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(currentUser.phoneNumber ?? "Unknown", style: const TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),

                    // --- ACTION BUTTON ---
                    isLoading.value
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isEdit.value) {
                            isLoading.value = true;
                            await profileController.updateUserProfile(
                              imageUrl: imagePath.value,
                              name: name.text.trim(),
                              about: about.text.trim(),
                              phoneNumber: currentUser.phoneNumber ?? "",
                            );
                            isLoading.value = false;
                            isEdit.value = false;
                          } else {
                            isEdit.value = true;
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEdit.value ? Theme.of(context).colorScheme.primary : Colors.white10,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(
                          isEdit.value ? "Save Changes" : "Edit Profile",
                          style: TextStyle(
                            color: isEdit.value ? Colors.black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(BuildContext context, String label, IconData icon, TextEditingController controller, bool isEdit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(isEdit ? 0.8 : 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isEdit ? Theme.of(context).colorScheme.primary.withOpacity(0.5) : Colors.transparent),
      ),
      child: TextField(
        controller: controller,
        enabled: isEdit,
        style: TextStyle(color: isEdit ? Colors.white : Colors.white70, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          border: InputBorder.none,
        ),
      ),
    );
  }
}