import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Pages/Chat/chatPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatting/Model/UserModel.dart';

class chatTile extends StatelessWidget {
  final UserModel userModel; // Update to use UserModel
  final String imageUrl;
  final String name;
  final String lastChat;
  final String lastSeen;

  const chatTile({
    super.key,
    required this.userModel, // Update to use UserModel
    required this.imageUrl,
    required this.name,
    required this.lastChat,
    required this.lastSeen,
  });

  @override
  Widget build(BuildContext context) {
    print("is displaying");
    ChatController contactController = Get.put(ChatController());
    return InkWell(
      onTap: () {
        Get.to(chatPage(userModel: userModel)); // Pass the userModel
        String roomId = contactController.getRoomId(userModel.id!); // Use userModel.id
        print("Room ID: $roomId");
      },
      child: Container(
        margin: const EdgeInsets.only(top: 4.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).colorScheme.surface,
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
                        child: Text(name, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(lastChat, style: Theme.of(context).textTheme.labelMedium),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(lastSeen),
            ),
          ],
        ),
      ),
    );
  }
}