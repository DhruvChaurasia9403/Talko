import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AllUsersController extends GetxController {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxBool isLoading = false.obs;
  RxList<UserModel> userList = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getUserList();
  }

  Future<void> getUserList() async {
    isLoading.value = true;
    try {
      final snapshot = await db.collection("users").get();
      userList.value = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
      // Exclude the current user from the list
          .where((user) => user.id != auth.currentUser!.uid)
          .toList();
    } catch (ex) {
      print(ex);
    }
    isLoading.value = false;
  }
}