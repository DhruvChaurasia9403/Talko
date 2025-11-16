import 'package:chatting/Model/ChatRoomModel.dart'; // <-- Change import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DBcontroller extends GetxController{
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;
  // Change userList to chatRoomList
  RxList<ChatRoomModel> chatRoomList = <ChatRoomModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    streamChatRooms(); // <-- Call new function
  }

  // Replace getUserLIst() with streamChatRooms()
  void streamChatRooms() {
    isLoading.value = true;
    try {
      db.collection("chats")
          .where("participants", arrayContains: auth.currentUser!.uid) // Query by participants
          .orderBy("lastMessageTimeStamp", descending: true) // Show newest chats first
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