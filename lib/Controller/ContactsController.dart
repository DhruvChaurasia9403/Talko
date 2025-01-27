import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';


class Contactscontroller extends GetxController{
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;


  RxBool isLoading = false.obs;
  RxList<UserModel> userList = <UserModel>[].obs;
  @override
  void onInit() async{
    super.onInit();
    await getUserLIst();
  }
  Future<void> getUserLIst() async{
    isLoading.value = true;
    print("is fetching");
    try{
      userList.clear();
      await db.collection("users").get().then(
              (value)=> {
            userList.value = value.docs.map((e)=> UserModel.fromJson(e.data())
            ).toList(),
          }
      );
    }catch(ex){
      print(ex);
    }
    isLoading.value = false;
  }
}