import 'package:chatting/Config/Strings.dart';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ImagePickerController.dart';
import 'package:chatting/Pages/Home/HomeWidgets/contactTile.dart';
import 'package:chatting/Pages/Home/HomeWidgets/tabBar.dart';
import 'package:chatting/Pages/Profile/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Controller/ProfileController.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    Get.put(ProfileController());

    ImagePickerController imagePickerController = Get.put(ImagePickerController());
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(AssetsImage.appIconSVG),
        ),
        actions: [
          IconButton(
            onPressed: (){
              imagePickerController.pickImage();
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: (){
              Get.to(()=>ProfilePage());
            },
            icon: Icon(Icons.more_vert),
          )
        ],
        title: Text(AppStrings.appName,style:Theme.of(context).textTheme.headlineSmall?.copyWith(color:Theme.of(context).colorScheme.secondary)),
        bottom:tabBar(tabController,context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Get.offAllNamed('/contactPage');
        },
        child: Icon(Icons.add,color:Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          contactTile(),
        ]
      )
    );
  }
}
