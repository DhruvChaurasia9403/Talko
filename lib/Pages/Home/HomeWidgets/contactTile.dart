// File: Pages/Home/HomeWidgets/contactTile.dart

import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/DBController.dart';
import 'package:chatting/Model/ChatRoomModel.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:chatting/Pages/Home/HomeWidgets/chatTile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Widgets/skeleton_chat_tile.dart';

class contactTile extends StatelessWidget {
  final RxString searchQuery;

  const contactTile({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    DBcontroller dbController = Get.put(DBcontroller());

    return Obx(() {
      if (dbController.isLoading.value) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 180, bottom: 120),
          itemCount: 8,
          itemBuilder: (context, index) {
            return const SkeletonChatTile();
          },
        );
      }

      String myUid = dbController.auth.currentUser!.uid;
      String query = searchQuery.value.toLowerCase();

      List<ChatRoomModel> filteredRooms =
      dbController.chatRoomList.where((room) {
        UserModel otherUser;

        if (room.sender?.id == myUid) {
          otherUser =
              room.receiver ?? UserModel(id: "unknown", name: "Unknown");
        } else {
          otherUser =
              room.sender ?? UserModel(id: "unknown", name: "Unknown");
        }

        return otherUser.name != null &&
            otherUser.name!.toLowerCase().contains(query);
      }).toList();

      if (filteredRooms.isEmpty) {
        return Center(
          child: Text(
            query.isEmpty ? "No chats found." : "No results for '$query'",
            style: const TextStyle(color: Colors.white54),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 180, bottom: 120),
        itemCount: filteredRooms.length,
        itemBuilder: (context, index) {
          final room = filteredRooms[index];

          UserModel otherUser;

          if (room.sender?.id == myUid) {
            otherUser =
                room.receiver ?? UserModel(id: "unknown", name: "Unknown");
          } else {
            otherUser =
                room.sender ?? UserModel(id: "unknown", name: "Unknown");
          }

          /// 🔥 FIXED UNREAD LOGIC
          int count = room.unReadMessageNo ?? 0;

          String? unreadCount;
          if (count > 0 && room.lastMessageSenderId != myUid) {
            unreadCount = count.toString();
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