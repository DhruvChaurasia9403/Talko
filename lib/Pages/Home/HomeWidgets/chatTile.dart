// File: Pages/Home/HomeWidgets/chatTile.dart

import 'package:chatting/Controller/ChatController.dart';
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
    bool hasUnread = (unreadCount != null && unreadCount != '0');

    return InkWell(
      onTap: () {
        Get.to(() => chatPage(userModel: userModel), transition: Transition.cupertino);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: hasUnread
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // --- HERO ANIMATION ADDED HERE ---
                Hero(
                  tag: 'profile_${userModel.id}',
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
                // --- END HERO ---
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Text(
                          lastChat,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: hasUnread
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.labelMedium?.color,
                          )
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (hasUnread)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                ),
                child: Text(
                  unreadCount!,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}