// File: Pages/Contact/ContactPage.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Pages/Contact/Widgets/ContactSearch.dart';
import 'package:chatting/Pages/Contact/Widgets/NewContactTile.dart';
import 'package:chatting/Pages/Home/HomeWidgets/chatTile.dart';

import '../../Controller/allUsersController.dart';

class Contactpage extends StatelessWidget {
  const Contactpage({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isSearchEnable = false.obs;
    // Use the new controller
    AllUsersController allUsersController = Get.put(AllUsersController()); // <-- CHANGED

    return WillPopScope(
      onWillPop: () async {
        Get.offNamed("/homePage");
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.offNamed("/homePage");
            },
          ),
          title: Text('contactSelect'.tr),
          actions: [
            Obx(() => IconButton(
              icon: isSearchEnable.value
                  ? const Icon(Icons.close)
                  : const Icon(Icons.search),
              onPressed: () {
                isSearchEnable.value = !isSearchEnable.value;
              },
            )),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Obx(() => isSearchEnable.value
                  ? const ContactSearch()
                  : const SizedBox(height: 2)),
              const SizedBox(height: 6),
              NewContactTile(
                btnName: 'contactNew'.tr,
                icon: Icons.person_add,
                onTap: () {},
              ),
              const SizedBox(height: 6),
              NewContactTile(
                btnName: 'contactNewGroup'.tr,
                icon: Icons.group_add,
                onTap: () {},
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                    'contactOnApp'.trParams({'appName': 'appName'.tr}),
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              Obx(() {
                if (allUsersController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Use the userList from the new controller
                return Column(
                  children: allUsersController.userList.map((e) => chatTile( // <-- CHANGED
                    userModel: e,
                    imageUrl: (e.profileImage?.isEmpty ?? true)
                        ? AssetsImage.defaultPic
                        : e.profileImage!,
                    name: e.name ?? 'contactDefaultName'.tr,
                    lastChat: e.about ?? 'contactDefaultAbout'.tr,
                    lastSeen: e.status ?? 'contactOnline'.tr, // Show user status
                    // No unreadCount is passed, so it will be null (correct)
                  )).toList(),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}