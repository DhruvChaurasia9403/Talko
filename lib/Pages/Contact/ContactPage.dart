import 'package:chatting/Controller/LocalContactsController.dart';
import '../../Controller/ThemeController.dart';
import 'package:chatting/Widgets/PremiumSurface.dart';
import 'package:chatting/Widgets/AmbientBackground.dart';
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
    final ThemeController themeController = Get.find<ThemeController>();
    final LocalContactsController contactsController = Get.put(LocalContactsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      contactsController.syncContacts();
    });

    return AmbientBackground(
      child: WillPopScope(
        onWillPop: () async {
          if (isSearchEnable.value) {
            isSearchEnable.value = false;
            searchQuery.value = "";
            return false;
          }
          Get.back();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.transparent, // Key to showing orbs
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: PremiumSurface(
              borderRadius: 0,
              child: SafeArea(
                bottom: false,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Obx(() => IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 20, color: themeController.text),
                    onPressed: () {
                      if (isSearchEnable.value) {
                        isSearchEnable.value = false;
                        searchQuery.value = "";
                      } else {
                        Get.back();
                      }
                    },
                  )),
                  title: Obx(() => isSearchEnable.value
                      ? const Text("")
                      : Text('Select Contact', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: themeController.text))),
                  actions: [
                    Obx(() => IconButton(
                      icon: Icon(isSearchEnable.value ? Icons.close : Icons.search, color: themeController.text),
                      onPressed: () {
                        isSearchEnable.value = !isSearchEnable.value;
                        searchQuery.value = "";
                      },
                    )),
                  ],
                ),
              ),
            ),
          ),
          body: Obx(() {
            if (contactsController.isLoading.value) {
              return Center(child: CircularProgressIndicator(color: themeController.primary));
            }
            return _buildContactList(context, contactsController, isSearchEnable, searchQuery, themeController);
          }),
        ),
      ),
    );
  }

  Widget _buildContactList(BuildContext context, LocalContactsController contactsController, RxBool isSearchEnable, RxString searchQuery, ThemeController themeController) {
    var filteredRegistered = contactsController.registeredContacts.where((e) {
      return (e.name ?? "").toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    var filteredUnregistered = contactsController.unregisteredContacts.where((e) {
      return (e.displayName ?? "").toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 120, left: 10, right: 10, bottom: 40),
      children: [
        if (isSearchEnable.value) ContactSearch(onChanged: (val) => searchQuery.value = val),
        if (isSearchEnable.value) const SizedBox(height: 10),

        if (!isSearchEnable.value) ...[
          NewContactTile(btnName: 'New Contact', icon: Icons.person_add, onTap: () {}),
          const SizedBox(height: 6),
          NewContactTile(btnName: 'New Group', icon: Icons.group_add, onTap: () => Get.to(() => const CreateGroupPage())),
          const SizedBox(height: 16),
        ],

        if (filteredRegistered.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text("Contacts on SAMPARK", style: TextStyle(color: themeController.primary, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ),
          ...filteredRegistered.map((e) => chatTile(
            userModel: e,
            imageUrl: (e.profileImage?.isEmpty ?? true) ? AssetsImage.defaultPic : e.profileImage!,
            name: e.name ?? 'Unknown',
            lastChat: e.about ?? 'Available',
            lastSeen: e.status ?? 'offline',
          )),
        ],

        if (filteredUnregistered.isNotEmpty) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text("Invite to SAMPARK", style: TextStyle(color: themeController.subText, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ),
          ...filteredUnregistered.map((contact) {
            final String displayName = contact.displayName ?? "Unknown";
            final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";
            final String phoneNumber = contact.phones.isNotEmpty ? (contact.phones.first.number ?? "") : "No number";

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              leading: Container(
                height: 50, width: 50,
                decoration: BoxDecoration(
                  color: themeController.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: themeController.primary.withAlpha(50)),
                ),
                child: Center(child: Text(initial, style: TextStyle(color: themeController.text, fontWeight: FontWeight.bold, fontSize: 18))),
              ),
              title: Text(displayName, style: TextStyle(color: themeController.text, fontWeight: FontWeight.w600)),
              subtitle: Text(phoneNumber, style: TextStyle(color: themeController.subText)),
              trailing: TextButton(
                onPressed: () => Get.snackbar("Invite Sent", "An SMS invite would be sent to $displayName."),
                child: Text("INVITE", style: TextStyle(color: themeController.primary, fontWeight: FontWeight.bold)),
              ),
            );
          }),
        ]
      ],
    );
  }
}