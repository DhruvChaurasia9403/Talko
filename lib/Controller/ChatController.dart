import 'package:chatting/Model/ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController{
  final auth = FirebaseAuth.instance;
  final db  = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;
  var uuid = Uuid();


  String getRoomId(String targetUserId) {
    String currentUserId = auth.currentUser!.uid;
    if (currentUserId[0].codeUnitAt(0) > targetUserId.codeUnitAt(0)) {
      return currentUserId + targetUserId;
    } else {
      return targetUserId + currentUserId;
    }
  }

  Future<void> sendMessage(String targetUserId , String message) async{
    isLoading.value = true;
    String chatId = uuid.v6();
    String roomId = getRoomId(targetUserId);
    var newChatModel = ChatModel(
      id:chatId,
      message: message,
    );
    try{
      await db.collection("chats").doc(roomId).collection("messages").doc(chatId).set(newChatModel.toJson());
    }
    catch(ex){
      print(ex);
    }
    isLoading.value = false;
  }
}