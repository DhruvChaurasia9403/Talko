import 'package:chatting/Controller/NotificationController.dart';
import 'package:chatting/Controller/ProfileController.dart';
import 'package:chatting/Model/ChatModel.dart';
import 'package:chatting/Model/ChatRoomModel.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;
  var uuid = const Uuid();
  final NotificationController notificationController;
  ProfileController profileController = Get.put(ProfileController());

  ChatController(this.notificationController);

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

    var roomDetails = ChatRoomModel(
      id: roomId,
      lastMessage: message,
      sender: profileController.currentUser.value,
      lastMessageTimeStamp: DateTime.now(),
      timeStamp: DateTime.now(),
      receiver: targetUser,
      unReadMessageNo: 0.toString(),
      messages: [newChatModel],
    );

    try {
      await db.collection("chats").doc(roomId).set(roomDetails.toJson());
      await db.collection("chats").doc(roomId).collection("messages").doc(chatId).set(newChatModel.toJson());

      // Trigger notification for the receiver
      await notificationController.showInstantNotification(
        title: "New Message from ${profileController.currentUser.value.name}",
        body: message,
      );
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