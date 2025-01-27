import 'package:chatting/Controller/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Widgets/profileInfo.dart';
class SenderProfilePage extends StatelessWidget {
  const SenderProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:const Icon(Icons.arrow_back_ios_new),
          onPressed: (){
            Get.offAllNamed('/homePage');
          },
        ),
        actions: [
          IconButton(
            onPressed: (){
              Get.offAllNamed('/updateProfile');
            },
            icon: const Icon(Icons.edit)),
        ],
        title:const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Profileinfo(),
            const Spacer(),
            ElevatedButton(
              onPressed: (){
                authController.logOutUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Log Out",style: Theme.of(context).textTheme.headlineSmall),
            )
          ],
        ),
      ),
    );
  }
}
