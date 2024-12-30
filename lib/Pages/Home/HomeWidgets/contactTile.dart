import 'package:chatting/Config/images.dart';
import 'package:chatting/Pages/Home/HomeWidgets/chatTile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class contactTile extends StatelessWidget {
  const contactTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        chatTile(
            imageUrl: AssetsImage.defaultPic,
            name:"kallu Kalia",
            lastChat: "mai too hu kalua",
            lastSeen: "time",
        ),
        chatTile(
          imageUrl: AssetsImage.defaultPic,
          name:"Dhruv",
          lastChat: "hey",
          lastSeen: "time",
        ),
      ],
    );
  }
}
