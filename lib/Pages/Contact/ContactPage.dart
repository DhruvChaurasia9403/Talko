import 'package:chatting/Config/Strings.dart';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Pages/Contact/Widgets/NewContactTile.dart';
import 'package:chatting/Pages/Home/HomeWidgets/chatTile.dart';
import 'package:flutter/material.dart';
class Contactpage extends StatelessWidget {
  const Contactpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Contact"),
        actions: [
          IconButton(
            icon: Icon(Icons.search,color: Theme.of(context).colorScheme.onBackground,),
            onPressed: (){},
          ),
        ],
      ),
      body:Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NewContactTile(
              btnName: "New Contact",
              icon: Icons.person_add,
              onTap: (){},
            ),
            SizedBox(height:6),
            NewContactTile(
              btnName: "New Contact",
              icon: Icons.person_add,
              onTap: (){},
            ),
            SizedBox(height:6),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("Contacts on ${AppStrings.appName}",style: Theme.of(context).textTheme.labelLarge),
            ),
            Column(
              children: [
                chatTile(
                  imageUrl: AssetsImage.girlPic,
                  name:"kallu Kalia",
                  lastChat: "mai too hu kalua",
                  lastSeen: "time",
                ),
                chatTile(
                  imageUrl: AssetsImage.boyPic,
                  name:"Dhruv",
                  lastChat: "hey",
                  lastSeen: "time",
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}
