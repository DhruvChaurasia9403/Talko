// File: Pages/Home/HomeWidgets/contactTile.dart

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

      String myUid = dbController.auth.currentUser!.uid;

      // --- BULLETPROOF NULL-SAFETY ---
      List<ChatRoomModel> filteredRooms = dbController.chatRoomList.where((room) {
        UserModel otherUser;
        if (room.sender != null && room.sender!.id == myUid) {
          otherUser = room.receiver ?? UserModel(id: "unknown", name: "Unknown User");
        } else if (room.receiver != null && room.receiver!.id == myUid) {
          otherUser = room.sender ?? UserModel(id: "unknown", name: "Unknown User");
        } else {
          otherUser = room.sender ?? room.receiver ?? UserModel(id: "unknown", name: "Unknown User");
        }

        return otherUser.name != null && otherUser.name!.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();

      if (filteredRooms.isEmpty) {
        return const Center(child: Text("No chats found.", style: TextStyle(color: Colors.white54)));
      }

      return ListView.builder(
        // --- UI OVERLAP FIX: Push list down 140px to clear the AppBar ---
        padding: const EdgeInsets.only(top: 165, bottom: 80),
        itemCount: filteredRooms.length,
        itemBuilder: (context, index) {
          final room = filteredRooms[index];

          // Safely determine the other user again
          UserModel otherUser;
          if (room.sender != null && room.sender!.id == myUid) {
            otherUser = room.receiver ?? UserModel(id: "unknown", name: "Unknown User");
          } else if (room.receiver != null && room.receiver!.id == myUid) {
            otherUser = room.sender ?? UserModel(id: "unknown", name: "Unknown User");
          } else {
            otherUser = room.sender ?? room.receiver ?? UserModel(id: "unknown", name: "Unknown User");
          }

          String? unreadCount;
          int count = int.tryParse(room.unReadMessageNo ?? '0') ?? 0;
          if (count > 0 && room.lastMessageSenderId != myUid) {
            unreadCount = room.unReadMessageNo;
          }

          return chatTile(
            userModel: otherUser,
            imageUrl: otherUser.profileImage ?? AssetsImage.defaultPic,
            name: otherUser.name ?? 'Unknown',
            lastChat: room.lastMessage ?? "Say hi!",
            lastSeen: "",
            unreadCount: unreadCount,
          );
        },
      );
    });
  }
}