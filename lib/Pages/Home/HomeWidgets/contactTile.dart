import 'package:chatting/Controller/DBController.dart';
import 'package:chatting/Pages/Home/HomeWidgets/chatTile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class contactTile extends StatelessWidget {
  final String searchQuery;

  const contactTile({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    DBcontroller dbController = Get.put(DBcontroller());

    return Obx(() {
      List filteredUsers = dbController.userList.where((user) {
        return user.name != null && user.name!.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();

      return ListView(
        children: filteredUsers.map((user) => chatTile(
          userModel: user,
          imageUrl: (user.profileImage?.isEmpty ?? true) ? "path/to/default/image" : user.profileImage!,
          name: user.name ?? "Name",
          lastChat: user.about ?? "hey there",
          lastSeen: user.email == dbController.auth.currentUser!.email ? "You" : "online",
        )).toList(),
      );
    });
  }
}
