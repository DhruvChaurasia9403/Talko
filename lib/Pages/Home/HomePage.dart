// File: Pages/Home/HomePage.dart

import 'dart:ui';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ImagePickerController.dart';
import 'package:chatting/Pages/Home/HomeWidgets/contactTile.dart';
import 'package:chatting/Pages/Home/HomeWidgets/tabBar.dart';
import 'package:chatting/Pages/Profile/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Controller/ProfileController.dart';
import '../../Controller/DBController.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

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
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.75),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(AssetsImage.appIconSVG),
              ),
              actions: [
                IconButton(
                  onPressed: () => showSearchDialog(),
                  icon: const Icon(Icons.search, size: 26),
                ),
                IconButton(
                  onPressed: () => Get.to(() => const ProfilePage()),
                  icon: const Icon(Icons.more_vert, size: 26),
                )
              ],
              title: Text(
                  'appName'.tr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  )
              ),
              bottom: tabBar(tabController, context),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "ai_fab",
            onPressed: () => Get.offAllNamed('/aiPage'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
            ),
            tooltip: 'homeAiTooltip'.tr,
            child: Icon(Icons.smart_toy, color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "contact_fab",
            onPressed: () => Get.offAllNamed('/contactPage'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            tooltip: 'homeContactTooltip'.tr,
            child: const Icon(Icons.add, color: Colors.black87, size: 28),
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          // --- FIX: Removed the Padding wrapper here! ---
          contactTile(searchQuery: searchQuery),
          Center(child: Text('homeTab2'.tr)),
          Center(child: Text('homeTab3'.tr)),
        ],
      ),
    );
  }

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('homeSearch'.tr),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'homeSearchBy'.tr,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (query) {
              setState(() => searchQuery = query);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('homeCancel'.tr, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }
}