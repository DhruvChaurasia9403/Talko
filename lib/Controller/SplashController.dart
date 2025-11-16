import 'package:cloud_firestore/cloud_firestore.dart'; // <-- ADD THIS
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // <-- ADD THIS
import 'package:get/get.dart';

class SplashController extends GetxController{
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance; // <-- ADD THIS
  final fcm = FirebaseMessaging.instance; // <-- ADD THIS

  @override
  void onInit() async{
    super.onInit();
    await splashHandle();
  }

  // --- ADD THIS NEW FUNCTION ---
  Future<void> _updateFcmToken() async {
    try {
      // 1. Get the new FCM token
      await fcm.requestPermission();
      final token = await fcm.getToken();
      print("My FCM Token: $token");

      // 2. Update it in Firestore for the current user
      if (token != null) {
        await db.collection("users").doc(auth.currentUser!.uid).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      print("Error updating FCM token: $e");
    }
  }
  // --- END OF NEW FUNCTION ---

  Future<void> splashHandle() async{
    Future.delayed(const Duration(seconds:2), () async { // <-- Make async
      if(auth.currentUser==null){
        Get.offAllNamed('/authPage');
      }
      else{
        // --- ADD THIS CALL ---
        // Update the token *before* going to the home page
        await _updateFcmToken();
        // ---------------------
        Get.offAllNamed('homePage');
        print(auth.currentUser!.email);
      }
    });
  }
}