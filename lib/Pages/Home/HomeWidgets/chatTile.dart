// File: Pages/Home/HomeWidgets/chatTile.dart

import 'package:chatting/Controller/ThemeController.dart';
import 'package:chatting/Pages/Chat/chatPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatting/Model/UserModel.dart';

class chatTile extends StatelessWidget {
  final UserModel userModel;
  final String imageUrl;
  final String name;
  final String lastChat;
  final String lastSeen;
  final String? unreadCount;

  const chatTile({
    super.key,
    required this.userModel,
    required this.imageUrl,
    required this.name,
    required this.lastChat,
    required this.lastSeen,
    this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUnread =
        unreadCount != null && unreadCount != "0" && unreadCount!.isNotEmpty;
    final ThemeController themeController = Get.find<ThemeController>();
    return InkWell(
      onTap: () {
        Get.to(() => chatPage(userModel: userModel),
            transition: Transition.cupertino);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: hasUnread
              ? themeController.isDark ? Colors.black : Colors.white
              : themeController.isDark ? Colors.black54 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: themeController.isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'profile_${userModel.id}',
                  child: Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                      Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: hasUnread
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Text(
                        lastChat,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                          color: hasUnread
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            /// 🔥 UNREAD BADGE
            if (hasUnread)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  unreadCount!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}