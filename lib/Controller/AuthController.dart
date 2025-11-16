// File: Controller/AuthController.dart

import 'package:chatting/Config/images.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class AuthController extends GetxController{
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final fcm = FirebaseMessaging.instance;
  RxBool isLoading = false.obs;


  //for login
  Future<void> login(String email,String password)async{
    isLoading.value=true;
    try{
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.offAllNamed('/homePage');
      print('authLoginSuccess'.tr); // <-- Changed (for debug)
    }on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found'){
        // You can show a snackbar here
        print('authLoginUserNotFound'.tr); // <-- Changed
      }
      else if(e.code == 'wrong-password'){
        print('authLoginWrongPassword'.tr); // <-- Changed
      }
    }catch(e){
      print(e);
    }
    isLoading.value=false;
  }


  Future <void> createUser(String email,String password,String name)async{
    isLoading.value = true;
    try{
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await initUser(email,name);
      Get.offAllNamed('/homePage');
      print('authSignUpSuccess'.tr); // <-- Changed
    }on FirebaseAuthException catch(e){
      if(e.code=='weak-password'){
        print('authSignUpWeakPassword'.tr); // <-- Changed
      }
      else if(e.code=='email-already-in-use'){
        print('authSignUpEmailInUse'.tr); // <-- Changed
      }
    }catch(e){
      print(e);
    }
    isLoading.value = false;
  }


  Future<void> logOutUser()async{
    await auth.signOut();
    Get.offAllNamed('/authPage');
  }




  Future<void> initUser(String email,String name) async {
    // --- Get FCM Token ---
    String? token;
    try {
      await fcm.requestPermission(); // Request permission
      token = await fcm.getToken();
      print("My FCM Token: $token");
    } catch (e) {
      print("Error getting FCM token: $e");
    }
    // ---------------------

    var newUser = UserModel(
      id: auth.currentUser!.uid,
      name: name,
      email: email,
      profileImage: AssetsImage.defaultPic,
      phoneNumber: "",
      fcmToken: token, // <-- Save the token here
    );
    try{
      await db.collection("users").doc(auth.currentUser!.uid).set(newUser.toJson());
    }
    catch(e){
      print (e);
    }
  }

}