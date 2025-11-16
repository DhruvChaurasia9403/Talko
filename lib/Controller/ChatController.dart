// File: Controller/ChatController.dart

import 'package:chatting/Controller/NotificationController.dart';
import 'package:chatting/Controller/ProfileController.dart';
import 'package:chatting/Model/ChatModel.dart';
import 'package:chatting/Model/ChatRoomModel.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http; // <-- ADD THIS
import 'dart:convert'; // <-- ADD THIS

class ChatController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;
  var uuid = const Uuid();
  final NotificationController notificationController;
  ProfileController profileController = Get.put(ProfileController());

  ChatController(this.notificationController);

  // --- ADD THIS NEW FUNCTION ---
  Future<void> _sendNotificationToServer(String receiverId, String message) async {
    // !!! REPLACE THIS WITH YOUR ACTUAL RENDER URL !!!
    final url = Uri.parse("https://chatting-server.onrender.com/sendNotification");

    final senderName = profileController.currentUser.value.name ?? "Someone";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'receiverId': receiverId,

          'senderName': senderName,
          'messageText': message,
        }),
      );
      if (response.statusCode == 200) {
        print("Notification server request successful.");
      } else {
        print("Notification server request failed: ${response.body}");
      }
    } catch (e) {
      print("Error calling notification server: $e");
    }
  }
  // --- END OF NEW FUNCTION ---

  String getRoomId(String targetUserId) {
    String currentUserId = auth.currentUser!.uid;
    if (currentUserId[0].codeUnitAt(0) > targetUserId.codeUnitAt(0)) {
      return currentUserId + targetUserId;
    } else {
      return targetUserId + currentUserId;
    }
  }

  Future<void> sendMessage(String targetUserId, String message, UserModel targetUser) async {
    isLoading.value = true;
    String chatId = uuid.v4();
    String roomId = getRoomId(targetUserId);
    var newChatModel = ChatModel(
      id: chatId,
      message: message,
      senderId: auth.currentUser!.uid,
      receiverId: targetUserId,
      timestamp: DateTime.now(),
      readStatus: 'sent',
    );

    final roomRef = db.collection("chats").doc(roomId);
    final doc = await roomRef.get();

    int newUnreadCount = 1;
    if (doc.exists) {
      try {
        ChatRoomModel oldRoom = ChatRoomModel.fromJson(doc.data()!);
        int oldCount = int.tryParse(oldRoom.unReadMessageNo ?? '0') ?? 0;
        newUnreadCount = oldCount + 1;
      } catch (e) {
        print("Error parsing old room, resetting count: $e");
      }
    }

    var roomDetails = ChatRoomModel(
      id: roomId,
      lastMessage: message,
      sender: profileController.currentUser.value,
      lastMessageTimeStamp: DateTime.now(),
      timeStamp: DateTime.now(),
      receiver: targetUser,
      unReadMessageNo: newUnreadCount.toString(),
      messages: [newChatModel],
      participants: [auth.currentUser!.uid, targetUserId],
    );

    try {
      await roomRef.set(roomDetails.toJson());
      await roomRef.collection("messages").doc(chatId).set(newChatModel.toJson());

      // --- UPDATE THIS ---
      // This call now happens *after* the message is saved
      await _sendNotificationToServer(targetUserId, message);
      // -------------------

    } catch (ex) {
      print(ex);
    }
    isLoading.value = false;
  }

  Stream<List<ChatModel>> getMessages(String targetUserId) {
    String roomId = getRoomId(targetUserId);
    return db.collection("chats")
        .doc(roomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatModel.fromJson(doc.data())).toList());
  }

  Future<void> updateMessageReadStatus(String roomId, String messageId) async {
    try {
      await db.collection("chats").doc(roomId).collection("messages").doc(messageId).update({
        'readStatus': 'read',
      });
    } catch (ex) {
      print(ex);
    }
  }
}