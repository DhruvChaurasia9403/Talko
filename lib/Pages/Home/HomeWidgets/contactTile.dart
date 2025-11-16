import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/DBController.dart';
import 'package:chatting/Model/ChatRoomModel.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:chatting/Pages/Home/HomeWidgets/chatTile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class contactTile extends StatelessWidget {
  final String searchQuery;
  const contactTile({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    DBcontroller dbController = Get.put(DBcontroller());

    return Obx(() {
      if (dbController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Filter logic now works on chat rooms
      List<ChatRoomModel> filteredRooms = dbController.chatRoomList.where((room) {
        // Determine who the *other* user in the chat is
        UserModel otherUser = (room.sender?.id == dbController.auth.currentUser!.uid)
            ? room.receiver!
            : room.sender!;

        // Search by the other user's name
        return otherUser.name != null &&
            otherUser.name!.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();

      if (filteredRooms.isEmpty) {
        return Center(child: Text("No chats found.")); // Handle empty state
      }

      return ListView.builder(
        itemCount: filteredRooms.length,
        itemBuilder: (context, index) {
          final room = filteredRooms[index];

          // Find the other user's details
          UserModel otherUser;
          // Check who sent the LAST message
          if (room.sender?.id == dbController.auth.currentUser!.uid) {
            otherUser = room.receiver!; // If I sent it, the other user is the receiver
          } else {
            otherUser = room.sender!; // Otherwise, the other user is the sender
          }

          // --- Unread Logic ---
          String? unreadCount;
          int count = int.tryParse(room.unReadMessageNo ?? '0') ?? 0;
          // Show count badge ONLY if I am the receiver and count > 0
          if (room.receiver?.id == dbController.auth.currentUser!.uid && count > 0) {
            unreadCount = room.unReadMessageNo;
          }
          // --- End Unread Logic ---

          return chatTile(
            userModel: otherUser, // Pass otherUser to navigate to chatPage
            imageUrl: otherUser.profileImage ?? AssetsImage.defaultPic,
            name: otherUser.name ?? 'contactDefaultName'.tr,
            lastChat: room.lastMessage ?? "...",
            lastSeen: "", // This field is no longer relevant, we use unreadCount
            unreadCount: unreadCount, // <-- Pass the unread count
          );
        },
      );
    });
  }
}