// File: Controller/GroupController.dart

import 'package:chatting/Model/ChatRoomModel.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class GroupController extends GetxController {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  var uuid = const Uuid();

  RxList<UserModel> selectedMembers = <UserModel>[].obs;
  RxBool isLoading = false.obs;

  void toggleMember(UserModel user) {
    if (selectedMembers.contains(user)) {
      selectedMembers.remove(user);
    } else {
      selectedMembers.add(user);
    }
  }

  Future<void> createGroup(String groupName, String? groupIconUrl) async {
    if (groupName.isEmpty || selectedMembers.isEmpty) {
      Get.snackbar("Error", "Please provide a group name and select members.");
      return;
    }

    isLoading.value = true;
    try {
      String roomId = uuid.v4(); // Generate a random, unique ID for the group

      // Combine selected members with the current user
      List<String> participantIds = selectedMembers.map((e) => e.id!).toList();
      participantIds.add(auth.currentUser!.uid);

      var groupRoom = ChatRoomModel(
        id: roomId,
        isGroup: true,
        groupName: groupName,
        groupIcon: groupIconUrl,
        adminIds: [auth.currentUser!.uid], // You are the admin!
        participants: participantIds,
        lastMessage: "Group created",
        timeStamp: DateTime.now(),
        lastMessageTimeStamp: DateTime.now(),
      );

      // Save the group to the database
      await db.collection("chats").doc(roomId).set(groupRoom.toJson());

      Get.offAllNamed("/homePage");
      Get.snackbar("Success", "Group '$groupName' created successfully!");
    } catch (e) {
      print("Error creating group: $e");
      Get.snackbar("Error", "Failed to create group.");
    } finally {
      isLoading.value = false;
      selectedMembers.clear();
    }
  }
}