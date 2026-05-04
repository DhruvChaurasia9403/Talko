import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ImagePickerController.dart';
import '../../Controller/ThemeController.dart'; // Mapped exactly as requested
import 'package:chatting/Pages/Home/HomeWidgets/contactTile.dart';
import 'package:chatting/Pages/Home/HomeWidgets/tabBar.dart';
import 'package:chatting/Pages/Profile/ProfilePage.dart';
import 'package:chatting/Widgets/PremiumSurface.dart';
import 'package:chatting/Widgets/AmbientBackground.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Controller/DBController.dart';
import '../../Controller/NotificationController.dart';
import '../../Controller/ProfileController.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = "".obs;
  final RxBool isSearching = false.obs;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Get.put(ProfileController()).getUserDetails();
      Get.put(DBcontroller()).streamChatRooms();
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
        debugPrint("FCM Setup Failed: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    Get.put(ProfileController());
    Get.put(DBcontroller());
    Get.put(ImagePickerController());

    // Wrap the entire screen in the Ambient Engine
    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let the orbs shine through
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: PremiumSurface(
                borderRadius: 30, // Sleek, floating capsule
                child: Obx(() => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        children: [
                          if (isSearching.value)
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: themeController.text),
                              onPressed: () {
                                isSearching.value = false;
                                searchQuery.value = "";
                                searchController.clear();
                              },
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: SvgPicture.asset(
                                AssetsImage.appIconSVG,
                                height: 28,
                                colorFilter: ColorFilter.mode(themeController.primary, BlendMode.srcIn),
                              ),
                            ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: isSearching.value
                                  ? TextField(
                                key: const ValueKey('search'),
                                controller: searchController,
                                autofocus: true,
                                style: TextStyle(color: themeController.text, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: "Search chats...",
                                  hintStyle: TextStyle(color: themeController.subText),
                                  border: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  isDense: true,
                                ),
                                onChanged: (val) => searchQuery.value = val,
                              )
                                  : Align(
                                key: const ValueKey('title'),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'SAMPARK',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: themeController.isDark ? themeController.orb2 : Colors.black26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (!isSearching.value)
                            IconButton(
                              onPressed: () => isSearching.value = true,
                              icon: Icon(Icons.search, size: 24, color: themeController.text),
                            ),
                          if (!isSearching.value)
                            IconButton(
                              onPressed: () => Get.to(() => const ProfilePage()),
                              icon: Icon(Icons.more_vert, size: 24, color: themeController.text),
                            )
                        ],
                      ),
                    ),
                    tabBar(tabController, context, themeController),
                  ],
                )),
              ),
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "ai_fab",
              onPressed: () => Get.toNamed('/aiPage'),
              backgroundColor: themeController.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blue.withAlpha(125), width: 1.5),
              ),
              child: Icon(Icons.smart_toy, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            Obx(() => FloatingActionButton(
              heroTag: "contact_fab",
              onPressed: () => Get.toNamed('/contactPage'),
              backgroundColor: themeController.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: themeController.isGlass ? 4 : 8,
              child: Icon(Icons.add, color: Colors.white, size: 30),
            )),
          ],
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            contactTile(searchQuery: searchQuery),
            Center(child: Obx(() => Text('Groups Coming Soon', style: TextStyle(color: themeController.subText)))),
            Center(child: Obx(() => Text('Calls Coming Soon', style: TextStyle(color: themeController.subText)))),
          ],
        ),
      ),
    );
  }
}