import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controller/ThemeController.dart';

PreferredSizeWidget tabBar(TabController tabController, BuildContext context, ThemeController themeController) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: Obx(() => TabBar(
      unselectedLabelStyle: TextStyle(
          color: themeController.subText,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: "Poppins"
      ),
      labelStyle: TextStyle(
          color: themeController.primary,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: "Poppins"
      ),
      indicatorWeight: 3,
      indicatorColor: themeController.primary,
      indicatorSize: TabBarIndicatorSize.label, // Underlines just the text, not the whole tab
      dividerColor: Colors.transparent,
      controller: tabController,
      tabs: [
        Tab(text: 'homeChats'.tr),
        Tab(text: 'homeGroup'.tr),
        Tab(text: 'homeCalls'.tr)
      ],
    )),
  );
}