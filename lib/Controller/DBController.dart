import 'dart:async';
import 'package:chatting/Model/ChatRoomModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:chatting/Model/LocalMessageModel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

class DBcontroller extends GetxController {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;
  RxList<ChatRoomModel> chatRoomList = <ChatRoomModel>[].obs;

  late Isar isar;
  StreamSubscription? _chatSubscription;

  // --- WORLD CLASS UPGRADE: ASYNC LOCK ---
  final Completer<void> _isarCompleter = Completer<void>();

  @override
  void onInit() {
    super.onInit();
    // Do not use async in onInit, let the future run and resolve the completer
    _initIsar().then((_) {
      _isarCompleter.complete(); // Unlocks the rest of the app!
      streamChatRooms();
      _listenForConnectivity();
    });
  }

  Future<void> _initIsar() async {
    // 1. SURVIVE HOT RELOADS: Check if Isar is already open in memory
    if (Isar.getInstance() != null) {
      isar = Isar.getInstance()!;
      return;
    }

    // 2. Open normally if it's a fresh launch
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [LocalMessageModelSchema],
      directory: dir.path,
    );
  }

  // --- NEW: Other controllers will await this before touching Isar ---
  Future<void> ensureIsarInitialized() async {
    if (!_isarCompleter.isCompleted) {
      await _isarCompleter.future;
    }
  }

  void _listenForConnectivity() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        syncPendingMessages();
      }
    });
  }

  Future<void> syncPendingMessages() async {
    if (auth.currentUser == null) return;

    final pendingMessages = await isar.localMessageModels
        .filter()
        .syncStatusEqualTo("pending")
        .findAll();

    if (pendingMessages.isEmpty) return;

    WriteBatch batch = db.batch();
    for (var localMsg in pendingMessages) {
      final String rId = localMsg.roomId ?? "unknown_room";
      final String msgId = localMsg.firestoreMessageId ?? "unknown_msg";

      final roomRef = db.collection("chats").doc(rId);
      final msgRef = roomRef.collection("messages").doc(msgId);

      // --- ADD THIS: Update the parent room during sync! ---
      batch.set(roomRef, {
        "id": rId,
        "participants": [localMsg.senderId, localMsg.receiverId],
        "lastMessage": localMsg.message,
        "lastMessageTimeStamp": localMsg.timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "lastMessageSenderId": localMsg.senderId,
      }, SetOptions(merge: true));
      // -----------------------------------------------------

      batch.set(msgRef, {
        "id": msgId,
        "message": localMsg.message,
        "senderId": localMsg.senderId,
        "receiverId": localMsg.receiverId,
        "timestamp": localMsg.timestamp,
        "readStatus": "sent",
        "imageUrl": localMsg.imageUrl,
      });

      localMsg.syncStatus = "synced";
    }

    try {
      await batch.commit();
      await isar.writeTxn(() async {
        for (var msg in pendingMessages) {
          await isar.localMessageModels.put(msg);
        }
      });
      print("Synced ${pendingMessages.length} offline messages to Firebase!");
    } catch (e) {
      print("Sync failed, will retry next time internet connects.");
    }
  }

  void streamChatRooms() {
    if (auth.currentUser == null) return;

    isLoading.value = true;
    _chatSubscription?.cancel();

    try {
      _chatSubscription = db.collection("chats")
          .where("participants", arrayContains: auth.currentUser!.uid)
          .orderBy("lastMessageTimeStamp", descending: true)
          .snapshots()
          .listen((snapshot) {
        chatRoomList.value = snapshot.docs
            .map((doc) => ChatRoomModel.fromJson(doc.data()))
            .toList();
        isLoading.value = false;
      }, onError: (ex) {
        print(ex);
        isLoading.value = false;
      });
    } catch (ex) {
      print(ex);
      isLoading.value = false;
    }
  }
}