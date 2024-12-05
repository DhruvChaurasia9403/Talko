import 'package:flutter/material.dart';
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
      tabs: const [
        Tab(
          text: "Chats",
        ),
        Tab(
          text: "Group",
        ),
        Tab(
          text: "Calls",
        )
      ],
    ),
  );
}