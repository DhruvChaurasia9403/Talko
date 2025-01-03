import 'package:chatting/Config/images.dart';
import 'package:chatting/Pages/Home/HomeWidgets/chatTile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatting/Controller/DBController.dart';

class contactTile extends StatelessWidget {
  const contactTile({super.key});

  @override
  Widget build(BuildContext context) {
    DBcontroller dbController = Get.put(DBcontroller());

    return Obx(() => ListView(
      children: dbController.userList.map((user) => chatTile(
        userModel: user,
        imageUrl: (user.profileImage?.isEmpty ?? true) ? AssetsImage.defaultPic : user.profileImage!,
        name: user.name ?? "Name",
        lastChat: user.about ?? "hey there",
        lastSeen: "Online",
      )).toList(),
    ));
  }
}