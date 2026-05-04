// File: Controller/AuthController.dart

import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final fcm = FirebaseMessaging.instance;

  RxBool isLoading = false.obs;
  String verificationId = "";
  String enteredPhoneNumber = ""; // Temporarily hold phone number during flow

  // --- 1. SEND OTP ---
  Future<void> sendOtp(String phoneNumber) async {
    isLoading.value = true;
    enteredPhoneNumber = phoneNumber;
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution on Android
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          Get.snackbar("Error", e.message ?? "Verification failed. Try again.");
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
          isLoading.value = false;
          Get.toNamed('/otpPage'); // Navigate to OTP screen
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Something went wrong.");
    }
  }

  // --- 2. VERIFY OTP ---
  Future<void> verifyOtp(String otp) async {
    isLoading.value = true;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar("Invalid OTP", "The code you entered is incorrect.");
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Failed to verify OTP.");
    }
  }

// --- 3. CORE SIGN-IN & ROUTING LOGIC ---
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if user already exists in Firestore
        DocumentSnapshot userDoc = await db.collection("users").doc(user.uid).get();

        if (userDoc.exists) {
          // Existing User -> Update FCM token and go Home
          await _updateFcmToken(user.uid);
          Get.offAllNamed('/homePage');
        } else {
          // New User -> Go to the new Onboarding flow!
          Get.offAllNamed('/onboardingPage'); // <-- THIS WAS THE FIX
        }
      }
    } catch (e) {
      // Print the exact error to the console so we can debug if it fails again
      print("SIGN IN ERROR: $e");

      // Safely show the snackbar
      if (Get.isSnackbarOpen != true) {
        Get.snackbar("Error", "Sign-in failed. Please try again.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- 4. FINALIZE NEW USER (Called after Profile Setup) ---
  Future<void> finalizeNewUser(String name, String about, String profileImageUrl) async {
    isLoading.value = true;
    try {
      String? token = await _getFcmToken();

      var newUser = UserModel(
        id: auth.currentUser!.uid,
        name: name,
        email: "", // Phone auth users don't have email by default
        profileImage: profileImageUrl,
        phoneNumber: enteredPhoneNumber, // Safe the verified phone number
        about: about,
        status: "online",
        fcmToken: token,
      );

      await db.collection("users").doc(auth.currentUser!.uid).set(newUser.toJson());
      Get.offAllNamed('/homePage');
    } catch (e) {
      Get.snackbar("Error", "Failed to setup profile.");
    }
    isLoading.value = false;
  }

  Future<void> logOutUser() async {
    await auth.signOut();
    Get.offAllNamed('/authPage');
  }

  Future<String?> _getFcmToken() async {
    try {
      await fcm.requestPermission();
      return await fcm.getToken();
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateFcmToken(String uid) async {
    String? token = await _getFcmToken();
    if (token != null) {
      await db.collection("users").doc(uid).update({'fcmToken': token});
    }
  }
}