// File: Pages/Contact/ContactPage.dart

import 'dart:ui';
import 'package:chatting/Controller/LocalContactsController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Pages/Contact/Widgets/ContactSearch.dart';
import 'package:chatting/Pages/Contact/Widgets/NewContactTile.dart';
import 'package:chatting/Pages/Home/HomeWidgets/chatTile.dart';
import '../Group/CreateGroupPage.dart';

class Contactpage extends StatelessWidget {
  const Contactpage({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isSearchEnable = false.obs;
    RxString searchQuery = "".obs;

    LocalContactsController contactsController = Get.put(LocalContactsController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      contactsController.syncContacts();
    });
    return WillPopScope(
      onWillPop: () async {
        // --- NEW: Fix back button behavior ---
        if (isSearchEnable.value) {
          isSearchEnable.value = false;
          searchQuery.value = "";
          return false; // Don't exit page, just close search
        }
        Get.back();
        return false;
      },
      child: Scaffold(
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
                  onPressed: () {
                    if (isSearchEnable.value) {
                      isSearchEnable.value = false;
                      searchQuery.value = "";
                    } else {
                      Get.back();
                    }
                  },
                ),
                title: Obx(() => isSearchEnable.value
                    ? const Text("") // Hide title when searching
                    : Text('Select Contact', style: Theme.of(context).textTheme.headlineSmall)),
                actions: [
                  Obx(() => IconButton(
                    icon: isSearchEnable.value ? const Icon(Icons.close) : const Icon(Icons.search),
                    onPressed: () {
                      isSearchEnable.value = !isSearchEnable.value;
                      searchQuery.value = ""; // Clear search on toggle
                    },
                  )),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (contactsController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- NEW: Filter logic ---
          var filteredRegistered = contactsController.registeredContacts.where((e) {
            return (e.name ?? "").toLowerCase().contains(searchQuery.value.toLowerCase());
          }).toList();

          var filteredUnregistered = contactsController.unregisteredContacts.where((e) {
            return (e.displayName ?? "").toLowerCase().contains(searchQuery.value.toLowerCase());
          }).toList();

          return ListView(
            padding: const EdgeInsets.only(top: 100, left: 10, right: 10, bottom: 40),
            children: [
              if (isSearchEnable.value)
                ContactSearch(
                  onChanged: (val) => searchQuery.value = val, // Update query as user types
                ),
              if (isSearchEnable.value) const SizedBox(height: 10),

              // Hide Add buttons if we are actively searching
              if (!isSearchEnable.value) ...[
                NewContactTile(btnName: 'New Contact', icon: Icons.person_add, onTap: () {}),
                const SizedBox(height: 6),
                NewContactTile(btnName: 'New Group', icon: Icons.group_add, onTap: () => Get.to(() => const CreateGroupPage())),
                const SizedBox(height: 16),
              ],

              // --- SECTION 1: REGISTERED ---
              if (filteredRegistered.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text("Contacts on SAMPARK", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                ...filteredRegistered.map((e) => chatTile(
                  userModel: e,
                  imageUrl: (e.profileImage?.isEmpty ?? true) ? AssetsImage.defaultPic : e.profileImage!,
                  name: e.name ?? 'Unknown',
                  lastChat: e.about ?? 'Available',
                  lastSeen: e.status ?? 'offline',
                )),
              ],

              // --- SECTION 2: UNREGISTERED ---
              if (filteredUnregistered.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text("Invite to SAMPARK", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                ),
                ...filteredUnregistered.map((contact) {
                  final String displayName = contact.displayName ?? "Unknown";
                  final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";
                  final String phoneNumber = contact.phones.isNotEmpty ? (contact.phones.first.number ?? "") : "No number";

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(phoneNumber, style: const TextStyle(color: Colors.white54)),
                    trailing: TextButton(
                      onPressed: () => Get.snackbar("Invite Sent", "An SMS invite would be sent to $displayName."),
                      child: Text("INVITE", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ),
                  );
                }),
              ]
            ],
          );
        }),
      ),
    );
  }
}