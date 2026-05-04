// File: Pages/Group/CreateGroupPage.dart

import 'dart:ui';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/GroupController.dart';
import 'package:chatting/Controller/ImagePickerController.dart';
import 'package:chatting/Controller/LocalContactsController.dart';
import 'package:chatting/Widgets/PrimaryButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.put(GroupController());
    final LocalContactsController contactsController = Get.find<LocalContactsController>();
    final ImagePickerController imagePickerController = Get.find<ImagePickerController>();

    final TextEditingController groupNameController = TextEditingController();
    final RxString groupImagePath = "".obs;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Get.back(),
              ),
              title: Text("Create Group", style: Theme.of(context).textTheme.headlineSmall),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 100), // Push below AppBar

          // --- GROUP INFO HEADER ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Obx(() => GestureDetector(
                  onTap: () async {
                    String? url = await imagePickerController.pickAndUploadImage();
                    if (url != null) groupImagePath.value = url;
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                    ),
                    child: imagePickerController.isUploading.value
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : groupImagePath.value.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(groupImagePath.value, fit: BoxFit.cover),
                    )
                        : const Icon(Icons.camera_alt, color: Colors.white70),
                  ),
                )),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: groupNameController,
                    decoration: InputDecoration(
                      hintText: "Group Subject",
                      hintStyle: const TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- MEMBER SELECTION LIST ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              "Select Participants",
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (contactsController.registeredContacts.isEmpty) {
                return const Center(child: Text("No contacts available to add."));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 0, bottom: 80),
                itemCount: contactsController.registeredContacts.length,
                itemBuilder: (context, index) {
                  final user = contactsController.registeredContacts[index];
                  bool isSelected = groupController.selectedMembers.contains(user);

                  return ListTile(
                    onTap: () => groupController.toggleMember(user),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.profileImage ?? AssetsImage.defaultPic),
                    ),
                    title: Text(user.name ?? "Unknown"),
                    subtitle: Text(user.about ?? "Hey there!"),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                        : const Icon(Icons.circle_outlined, color: Colors.white30),
                  );
                },
              );
            }),
          ),
        ],
      ),

      // --- CREATE BUTTON ---
      floatingActionButton: Obx(() => groupController.selectedMembers.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () {
          groupController.createGroup(groupNameController.text.trim(), groupImagePath.value);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: groupController.isLoading.value
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
            : const Icon(Icons.check, color: Colors.black),
        label: Text(
          groupController.isLoading.value ? "Creating..." : "Create Group",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      )
          : const SizedBox.shrink()),
    );
  }
}