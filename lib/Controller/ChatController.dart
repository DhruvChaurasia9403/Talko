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
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;
  var uuid = const Uuid();
  final NotificationController notificationController;
  ProfileController profileController = Get.put(ProfileController());

  // --- NEW: MESSAGE SELECTION STATE ---
  RxList<String> selectedMessageIds = <String>[].obs;

  void toggleMessageSelection(String messageId) {
    if (selectedMessageIds.contains(messageId)) {
      selectedMessageIds.remove(messageId);
    } else {
      selectedMessageIds.add(messageId);
    }
  }

  void clearSelection() {
    selectedMessageIds.clear();
  }

  Future<void> deleteSelectedMessages(String targetUserId) async {
    String roomId = getRoomId(targetUserId);
    try {
      for (String msgId in selectedMessageIds) {
        await db.collection("chats").doc(roomId).collection("messages").doc(msgId).delete();
      }
      clearSelection();
    } catch (e) {
      print("Error deleting messages: $e");
    }
  }
  // ------------------------------------

  // --- SMART AI REPLIES STATE ---
  RxList<String> smartReplies = <String>[].obs;
  RxBool isFetchingReplies = false.obs;

  ChatController(this.notificationController);

  Future<void> _sendNotificationToServer(String receiverId, String message) async {
    final url = Uri.parse("https://chatting-server-17pa.onrender.com/sendNotification");
    final senderName = profileController.currentUser.value.name ?? "Someone";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'receiverId': receiverId,
          'senderName': senderName,
          'messageText': message,
          'senderId': auth.currentUser!.uid,
        }),
      );
      if (response.statusCode != 200) {
        print("Notification server request failed: ${response.body}");
      }
    } catch (e) {
      print("Error calling notification server: $e");
    }
  }

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
      participants: [auth.currentUser!.uid, targetUserId],
    );

    try {
      await roomRef.set(roomDetails.toJson());
      await roomRef.collection("messages").doc(chatId).set(newChatModel.toJson());
      await _sendNotificationToServer(targetUserId, message);

      // --- INTERCEPT @VOID COMMAND ---
      if (message.trim().toUpperCase().startsWith("@VOID")) {
        String prompt = message.trim().substring(5).trim();
        if (prompt.isNotEmpty) {
          _triggerVoidAssistant(roomId, prompt);
        }
      }
    } catch (ex) {
      print(ex);
    }
    isLoading.value = false;
  }

  Future<void> _triggerVoidAssistant(String roomId, String prompt) async {
    try {
      db.collection("chats").doc(roomId).set({'typing_VOID': true}, SetOptions(merge: true));
      final url = Uri.parse("https://chatting-server-17pa.onrender.com/askVoid");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String voidResponse = data['response'];

        String voidChatId = uuid.v4();
        var voidMessageModel = ChatModel(
          id: voidChatId,
          message: voidResponse,
          senderId: "VOID",
          senderName: "V.O.I.D. System",
          timestamp: DateTime.now(),
          readStatus: 'read',
        );

        await db.collection("chats").doc(roomId).collection("messages").doc(voidChatId).set(voidMessageModel.toJson());

        await db.collection("chats").doc(roomId).update({
          'lastMessage': "✨ V.O.I.D. replied",
          'lastMessageTimeStamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print("V.O.I.D. Error: $e");
    } finally {
      db.collection("chats").doc(roomId).set({'typing_VOID': false}, SetOptions(merge: true));
    }
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

  // --- TYPING INDICATORS ---
  void updateTypingStatus(String targetUserId, bool isTyping) {
    String roomId = getRoomId(targetUserId);
    db.collection("chats").doc(roomId).set({
      'typing_${auth.currentUser!.uid}': isTyping
    }, SetOptions(merge: true));
  }

  Stream<bool> getTypingStatus(String targetUserId) {
    String roomId = getRoomId(targetUserId);
    return db.collection("chats").doc(roomId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return doc.data()!['typing_$targetUserId'] ?? false;
      }
      return false;
    });
  }

  // --- SMART REPLIES ---
  Future<void> fetchSmartReplies(List<ChatModel> recentMessages) async {
    if (recentMessages.isEmpty || recentMessages.last.senderId == auth.currentUser!.uid) {
      smartReplies.clear();
      return;
    }

    isFetchingReplies.value = true;
    try {
      var lastFive = recentMessages.length > 5 ? recentMessages.sublist(recentMessages.length - 5) : recentMessages;
      String contextString = lastFive.map((m) {
        String speaker = m.senderId == auth.currentUser!.uid ? "Me" : "Them";
        return "$speaker: ${m.message}";
      }).join("\n");

      final url = Uri.parse("https://chatting-server-17pa.onrender.com/generateSmartReplies");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'chatContext': contextString}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> generatedReplies = data['replies'];
        smartReplies.value = generatedReplies.cast<String>();
      }
    } catch (e) {
      print("Error fetching smart replies: $e");
      smartReplies.clear();
    } finally {
      isFetchingReplies.value = false;
    }
  }
}