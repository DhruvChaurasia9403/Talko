import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatting/Config/Strings.dart';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Pages/Contact/Widgets/ContactSearch.dart';
import 'package:chatting/Pages/Contact/Widgets/NewContactTile.dart';
import 'package:chatting/Pages/Home/HomeWidgets/chatTile.dart';

class Contactpage extends StatelessWidget {
  const Contactpage({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isSearchEnable = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text("Select Contact"),
        actions: [
          Obx(() => IconButton(
            icon: isSearchEnable.value
                ? Icon(Icons.close)
                : Icon(Icons.search),
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
                ? ContactSearch()
                : SizedBox(height: 2)),
            SizedBox(height: 6),
            NewContactTile(
              btnName: "New Contact",
              icon: Icons.person_add,
              onTap: () {},
            ),
            SizedBox(height: 6),
            NewContactTile(
              btnName: "New Group",
              icon: Icons.group_add,
              onTap: () {},
            ),
            SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("Contacts on ${AppStrings.appName}",
                  style: Theme.of(context).textTheme.labelLarge),
            ),
            const Column(
              children: [
                chatTile(
                  imageUrl: AssetsImage.girlPic,
                  name: "kallu Kalia",
                  lastChat: "mai too hu kalua",
                  lastSeen: "time",
                ),
                chatTile(
                  imageUrl: AssetsImage.boyPic,
                  name: "Dhruv",
                  lastChat: "hey",
                  lastSeen: "time",
                ),
                chatTile(
                  imageUrl: AssetsImage.girlPic,
                  name: "kallu Kalia",
                  lastChat: "mai too hu kalua",
                  lastSeen: "time",
                ),
                chatTile(
                  imageUrl: AssetsImage.boyPic,
                  name: "Dhruv",
                  lastChat: "hey",
                  lastSeen: "time",
                ),
                chatTile(
                  imageUrl: AssetsImage.girlPic,
                  name: "kallu Kalia",
                  lastChat: "mai too hu kalua",
                  lastSeen: "time",
                ),
                chatTile(
                  imageUrl: AssetsImage.boyPic,
                  name: "Dhruv",
                  lastChat: "hey",
                  lastSeen: "time",
                ),
                chatTile(
                  imageUrl: AssetsImage.girlPic,
                  name: "kallu Kalia",
                  lastChat: "mai too hu kalua",
                  lastSeen: "time",
                ),
                chatTile(
                  imageUrl: AssetsImage.boyPic,
                  name: "Dhruv",
                  lastChat: "hey",
                  lastSeen: "time",
                ),
                chatTile(
                  imageUrl: AssetsImage.girlPic,
                  name: "kallu Kalia",
                  lastChat: "mai too hu kalua",
                  lastSeen: "time",
                ),
                chatTile(
                  imageUrl: AssetsImage.boyPic,
                  name: "Dhruv",
                  lastChat: "hey",
                  lastSeen: "time",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
