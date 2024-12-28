import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../Model/ChatModel.dart';

class Contactscontroller extends GetxController{
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;


  void onInit() async{
    super.onInit();
    await getUserLIst();
  }
  RxBool isLoading = false.obs;
  RxList<UserModel> userList = <UserModel>[].obs;
  Future<void> getUserLIst() async{
    isLoading.value = true;
    try{
      userList.clear();
      await db.collection("users").get().then(
              (value)=> {
            userList.value = value.docs.map(
                    (e)=> UserModel.fromJson(e.data() as Map<String, dynamic>)
            ).toList(),
          }
      );
    }catch(ex){
      print(ex);
    }
    isLoading.value = false;
  }
}