// File: Controller/ChatController.dart

import 'package:chatting/Controller/NotificationController.dart';
import 'package:chatting/Controller/ProfileController.dart';
import 'package:chatting/Model/ChatModel.dart';
import 'package:isar/isar.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Model/LocalMessageModel.dart';
import 'DBController.dart';

class ChatController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;
  var uuid = const Uuid();
  final NotificationController notificationController;

  ProfileController get profileController => Get.put(ProfileController());

  RxInt messageLimit = 30.obs;
  RxBool isFetchingMore = false.obs;

  RxBool isVoidTyping = false.obs;

  ChatController(this.notificationController);

  void loadMoreMessages() {
    messageLimit.value += 30;
  }

  void resetMessageLimit() {
    messageLimit.value = 30;
  }

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

  RxList<String> smartReplies = <String>[].obs;
  RxBool isFetchingReplies = false.obs;

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
        print("Notification server failed: ${response.body}");
      }
    } catch (e) {
      print("Error calling notification server: $e");
    }
  }

  String getRoomId(String targetUserId) {
    String currentUserId = auth.currentUser!.uid.trim();
    String targetId = targetUserId.trim();
    List<String> users = [currentUserId, targetId];
    users.sort();
    return users.join("_");
  }

  Future<void> _pingFirebaseToUpdateUI(String roomId) async {
    try {
      final pingRef = db.collection("chats").doc(roomId).collection("messages").doc("UI_PING_${auth.currentUser!.uid}");
      await pingRef.set({
        "ping": DateTime.now().millisecondsSinceEpoch,
        "timestamp": DateTime.now().toIso8601String()
      });
    } catch (e) {
      print("Ping failed: $e");
    }
  }

  Future<void> sendMessage(String targetUserId, String message, UserModel targetUser, {String? imageUrl}) async {
    if (targetUserId.isEmpty) return;

    String chatId = uuid.v4();
    String roomId = getRoomId(targetUserId);
    String myUid = auth.currentUser!.uid;

    final dbController = Get.find<DBcontroller>();
    await dbController.ensureIsarInitialized();

    bool isVoidCommand = message.toLowerCase().contains("@void");

    var localMsg = LocalMessageModel()
      ..firestoreMessageId = chatId
      ..roomId = roomId
      ..message = message
      ..senderId = myUid
      ..receiverId = targetUserId
      ..timestamp = DateTime.now()
      ..imageUrl = imageUrl
      ..syncStatus = isVoidCommand ? "local_only" : "pending";

    await dbController.isar.writeTxn(() async {
      await dbController.isar.localMessageModels.put(localMsg);
    });

    if (isVoidCommand) {
      _pingFirebaseToUpdateUI(roomId);
      _triggerVoidAssistant(roomId, message, targetUserId);
      return;
    }

    final roomRef = db.collection("chats").doc(roomId);
    try {
      WriteBatch batch = db.batch();


      var roomUpdate = {
        "id": roomId,
        "participants": [myUid, targetUserId],
        "lastMessage": imageUrl != null ? "📷 Photo" : message,
        "lastMessageTimeStamp": DateTime.now().toIso8601String(),
        "lastMessageSenderId": myUid,
        "sender": profileController.currentUser.value.toJson(),
        "receiver": targetUser.toJson(),
        "unReadMessageNo": FieldValue.increment(1), // <-- ADD THIS LINE
      };

      batch.set(roomRef, roomUpdate, SetOptions(merge: true));

      var newChatModel = ChatModel(
        id: chatId,
        message: message,
        senderId: myUid,
        receiverId: targetUserId,
        senderName: profileController.currentUser.value.name,
        timestamp: DateTime.now(),
        readStatus: 'sent',
        imageUrl: imageUrl,
      );

      batch.set(roomRef.collection("messages").doc(chatId), newChatModel.toJson());

      await batch.commit();

      await dbController.isar.writeTxn(() async {
        localMsg.syncStatus = "synced";
        await dbController.isar.localMessageModels.put(localMsg);
      });

      _sendNotificationToServer(targetUserId, message);

    } catch (ex) {
      print("Message queued offline: $ex");
    }
  }

  // --- THE CRITICAL FIX: ALWAYS SAVE A RESPONSE EVEN ON SERVER ERROR ---
  Future<void> _triggerVoidAssistant(String roomId, String prompt, String targetUserId) async {
    final dbController = Get.find<DBcontroller>();
    isVoidTyping.value = true;

    // Default error message just in case the server fails
    String finalReply = "System: V.O.I.D. encountered an unknown error.";

    try {
      final url = Uri.parse("https://chatting-server-17pa.onrender.com/askVoid");

      // Render cold starts take ~40 seconds. We must allow enough time for it to wake up.
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String voidResponse = data['response'];
        finalReply = voidResponse.replaceAll(RegExp(r'\*\*|\*'), '').trim();
      } else {
        // Capture specific server errors (e.g. Gemini quota exceeded, bad request)
        finalReply = "System: Server returned Error ${response.statusCode}\nDetails: ${response.body}";
      }
    } catch (e) {
      print("V.O.I.D. Error: $e");
      // If Render was asleep and it timed out, tell the user!
      finalReply = "System: Connection timed out or failed. Error: $e";
    } finally {
      // --- ALWAYS SAVE THE MESSAGE SO THE UI SPINNER DOESN'T VANISH SILENTLY ---
      var localVoidMsg = LocalMessageModel()
        ..firestoreMessageId = uuid.v4()
        ..roomId = roomId
        ..message = finalReply
        ..senderId = "VOID"
        ..receiverId = auth.currentUser!.uid
        ..timestamp = DateTime.now()
        ..syncStatus = "local_only";

      await dbController.isar.writeTxn(() async {
        await dbController.isar.localMessageModels.put(localVoidMsg);
      });

      _pingFirebaseToUpdateUI(roomId); // Wake UI for AI response
      isVoidTyping.value = false;
    }
  }

  Stream<List<ChatModel>> getMessages(String targetUserId) {
    String roomId = getRoomId(targetUserId);
    final dbController = Get.find<DBcontroller>();
    String myUid = auth.currentUser!.uid;

    return db.collection("chats")
        .doc(roomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(messageLimit.value)
        .snapshots()
        .asyncMap((snapshot) async {

      await dbController.ensureIsarInitialized();

      var fbMessages = snapshot.docs
          .where((doc) => !doc.id.contains("UI_PING"))
          .map((doc) => ChatModel.fromJson(doc.data()))
          .toList();

      var allLocal = await dbController.isar.localMessageModels
          .filter()
          .roomIdEqualTo(roomId)
          .findAll();

      List<LocalMessageModel> secureLocal = allLocal.where((msg) {
        bool isPendingOrLocal = msg.syncStatus == "pending" || msg.syncStatus == "local_only";
        if (msg.syncStatus == "local_only") {
          return isPendingOrLocal && (msg.senderId == myUid || msg.receiverId == myUid);
        }
        return isPendingOrLocal;
      }).toList();

      var localFb = secureLocal.map((local) {
        String resolvedStatus = "unknown";
        if (local.syncStatus == "local_only") {
          resolvedStatus = local.senderId == myUid ? "sent" : "read";
        }

        return ChatModel(
          id: local.firestoreMessageId ?? "temp_id",
          message: local.message ?? "",
          senderId: local.senderId ?? "",
          receiverId: local.receiverId ?? "",
          timestamp: local.timestamp ?? DateTime.now(),
          readStatus: resolvedStatus,
          imageUrl: local.imageUrl,
        );
      }).toList();

      var combined = [...localFb, ...fbMessages];

      final Map<String, ChatModel> uniqueMessages = {};
      for (var msg in combined) {
        if (msg.id != null) uniqueMessages[msg.id!] = msg;
      }

      var finalList = uniqueMessages.values.toList();
      finalList.sort((a, b) {
        DateTime timeA = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        DateTime timeB = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        return timeB.compareTo(timeA);
      });

      return finalList.reversed.toList();
    });
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