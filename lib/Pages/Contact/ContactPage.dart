import 'package:chatting/Controller/ContactsController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatting/Config/Strings.dart';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Pages/Contact/Widgets/ContactSearch.dart';
import 'package:chatting/Pages/Contact/Widgets/NewContactTile.dart';
import 'package:chatting/Pages/Home/HomeWidgets/chatTile.dart';
import 'package:chatting/Model/UserModel.dart'; // Ensure this import is correct

class Contactpage extends StatelessWidget {
  const Contactpage({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isSearchEnable = false.obs;
    Contactscontroller contactscontroller = Get.put(Contactscontroller());
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
            Obx(()=>Column(
              children: contactscontroller.userList.map((e)=> chatTile(
                userModel: e,
                imageUrl: (e.profileImage?.isEmpty ?? true) ? AssetsImage.defaultPic : e.profileImage!,
                name: e.name??"Name",
                lastChat: e.about??"hey there",
                lastSeen: "Online",
              )).toList(),
            ),
            )
          ],
        ),
      ),
    );
  }
}