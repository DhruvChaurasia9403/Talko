// File: Pages/Home/HomePage.dart

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

    ImagePickerController imagePickerController = Get.put(ImagePickerController());
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(AssetsImage.appIconSVG),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearchDialog();
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Get.to(() => const ProfilePage());
            },
            icon: const Icon(Icons.more_vert),
          )
        ],
        title: Text(
            'appName'.tr, // <-- Changed
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary
            )
        ),
        bottom: tabBar(tabController, context),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Get.offAllNamed('/aiPage');
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.smart_toy, color: Colors.white),
            tooltip: 'homeAiTooltip'.tr, // <-- Changed
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Get.offAllNamed('/contactPage');
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
            tooltip: 'homeContactTooltip'.tr, // <-- Changed
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          contactTile(searchQuery: searchQuery),
          Center(child: Text('homeTab2'.tr)), // <-- Changed
          Center(child: Text('homeTab3'.tr)), // <-- Changed
        ],
      ),
    );
  }

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('homeSearch'.tr), // <-- Changed
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(hintText: 'homeSearchBy'.tr), // <-- Changed
            onChanged: (query) {
              setState(() {
                searchQuery = query;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('homeCancel'.tr), // <-- Changed
            ),
          ],
        );
      },
    );
  }
}