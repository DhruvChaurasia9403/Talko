import 'package:chatting/Controller/ContactsController.dart';
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
    Contactscontroller contactscontroller = Get.put(Contactscontroller());

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
          title: const Text("Select Contact"),
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
                btnName: "New Contact",
                icon: Icons.person_add,
                onTap: () {},
              ),
              const SizedBox(height: 6),
              NewContactTile(
                btnName: "New Group",
                icon: Icons.group_add,
                onTap: () {},
              ),
              const SizedBox(height: 6),
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
                  lastSeen: e.email == contactscontroller.auth.currentUser!.email
                      ?"you"
                      :"online",
                )).toList(),
              ),
              )
            ],
          ),
        ),
      ),
    );
  }
}