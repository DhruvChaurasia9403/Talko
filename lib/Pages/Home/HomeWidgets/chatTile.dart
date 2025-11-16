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
  final String? unreadCount; // <-- ADD THIS

  const chatTile({
    super.key,
    required this.userModel,
    required this.imageUrl,
    required this.name,
    required this.lastChat,
    required this.lastSeen,
    this.unreadCount, // <-- ADD THIS
  });

  @override
  Widget build(BuildContext context) {
    ChatController contactController = Get.find<ChatController>();
    bool hasUnread = (unreadCount != null && unreadCount != '0'); // Check for unread

    return InkWell(
      onTap: () {
        Get.to(chatPage(userModel: userModel));
        String roomId = contactController.getRoomId(userModel.id!);
        print("Room ID: $roomId");
      },
      child: Container(
        margin: const EdgeInsets.only(top: 4.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          // Highlight container if unread
          color: hasUnread
              ? Theme.of(context).colorScheme.primary.withAlpha(50)
              : Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 70,
                    width: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        imageUrl,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            // Bold name if unread
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                            lastChat,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              // Make last message bold too, if you want
                              color: hasUnread
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).textTheme.labelMedium?.color,
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // --- This is the new Unread Badge ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: hasUnread
                  ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
                  : const SizedBox.shrink(), // Show nothing if no unread messages
            ),
            // --- End of Unread Badge ---
          ],
        ),
      ),
    );
  }
}