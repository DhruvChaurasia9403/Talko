// File: Pages/Home/HomePage.dart

import 'dart:ui';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ImagePickerController.dart';
import 'package:chatting/Pages/Home/HomeWidgets/contactTile.dart';
import 'package:chatting/Pages/Home/HomeWidgets/tabBar.dart';
import 'package:chatting/Pages/Profile/ProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Controller/DBController.dart';
import '../../Controller/LocalContactsController.dart';
import '../../Controller/NotificationController.dart';
import '../../Controller/ProfileController.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = "".obs; // Track search locally
  final RxBool isSearching = false.obs; // Toggle UI state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Load Data
      Get.put(ProfileController()).getUserDetails();
      Get.put(DBcontroller()).streamChatRooms();

      // 2. NOW ask for permissions (Over the Home Page, safely)
      final notifController = Get.find<NotificationController>();
      await notifController.initializeNotifications();

      try {
        final fcm = FirebaseMessaging.instance;
        await fcm.requestPermission();
        final token = await fcm.getToken();
        if (token != null) {
          FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({'fcmToken': token});
        }
      } catch (e) {
        print("FCM Setup Failed: $e");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    Get.put(ProfileController());
    Get.put(DBcontroller());
    Get.put(ImagePickerController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Obx(() => AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.75),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: isSearching.value
                  ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  isSearching.value = false;
                  searchQuery.value = "";
                  searchController.clear();
                },
              )
                  : Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(AssetsImage.appIconSVG),
              ),
              title: isSearching.value
                  ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: "Search chats...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (val) => searchQuery.value = val,
              )
                  : Text(
                'SAMPARK',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              actions: [
                if (!isSearching.value)
                  IconButton(
                    onPressed: () => isSearching.value = true,
                    icon: const Icon(Icons.search, size: 26),
                  ),
                if (!isSearching.value)
                  IconButton(
                    onPressed: () => Get.to(() => const ProfilePage()),
                    icon: const Icon(Icons.more_vert, size: 26),
                  )
              ],
              bottom: tabBar(tabController, context),
            )),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "ai_fab",
            onPressed: () => Get.toNamed('/aiPage'), // <-- FIXED
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
            ),
            child: Icon(Icons.smart_toy, color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "contact_fab",
            onPressed: () => Get.toNamed('/contactPage'), // <-- FIXED
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            child: const Icon(Icons.add, color: Colors.black87, size: 28),
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          // Wrap in Obx to pass the reactive value down
          Obx(() => contactTile(searchQuery: searchQuery.value)),
          const Center(child: Text('Groups Coming Soon')),
          const Center(child: Text('Calls Coming Soon')),
        ],
      ),
    );
  }
}