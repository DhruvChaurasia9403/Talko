// File: Pages/SenderProfile/senderProfilePage.dart

import 'package:chatting/Config/images.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Widgets/profileInfo.dart';
class SenderProfilePage extends StatelessWidget {
  final UserModel userModel;
  const SenderProfilePage({super.key , required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:const Icon(Icons.arrow_back_ios_new),
          onPressed: (){
            Get.offAllNamed('/homePage');
          },
        ),
        // Using trParams for dynamic profile title
        title: Text(
            'profileSenderTitle'.trParams({ // <-- Changed
              'name': userModel.name ?? 'profileSenderDefaultUser'.tr
            }),
            style: Theme.of(context).textTheme.headlineSmall
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Profileinfo(
              imageUrl: userModel.profileImage ?? AssetsImage.defaultPic,
              name: userModel.name ?? 'profileSenderDefaultUser'.tr, // <-- Changed
              email: userModel.email ?? 'profileSenderDefaultEmail'.tr, // <-- Changed
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}