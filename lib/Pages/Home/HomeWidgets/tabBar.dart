// File: Pages/Home/HomeWidgets/tabBar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // <-- Import Get

tabBar(TabController tabController,BuildContext context){
  return PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child:  TabBar(
      unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
      labelStyle: Theme.of(context).textTheme.bodyLarge,
      indicatorWeight: 10,
      indicatorColor: Theme.of(context).colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(100)
      ),
      controller: tabController,
      tabs: [
        Tab(
          text: 'homeChats'.tr, // <-- Changed
        ),
        Tab(
          text: 'homeGroup'.tr, // <-- Changed
        ),
        Tab(
          text: 'homeCalls'.tr, // <-- Changed
        )
      ],
    ),
  );
}