// File: Controller/ProfileController.dart

import 'package:chatting/Config/images.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../Model/LocalMessageModel.dart';
import 'DBController.dart'; // <-- Needed for Isar wipe

class ProfileController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  Rx<UserModel> currentUser = UserModel().obs;

  @override
  void onInit() async {
    super.onInit();
    if (auth.currentUser != null) {
      await getUserDetails();
      updateOnlineStatus(true);
    }
  }

  @override
  void onClose() {
    super.onClose();
    updateOnlineStatus(false);
  }

  Future<void> getUserDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await db
          .collection('users')
          .doc(auth.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        currentUser.value = UserModel.fromJson(userDoc.data()!);
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  void updateOnlineStatus(bool isOnline) {
    if (auth.currentUser != null) {
      db.collection('users').doc(auth.currentUser!.uid).update({
        'status': isOnline ? 'online' : 'offline',
        'lastSeen': isOnline ? null : FieldValue.serverTimestamp(),
      });
    }
  }

  Future<String?> uploadImageToCloudinary(String imagePath) async {
    try {
      const cloudName = "dgsxsujn9";
      const uploadPreset = "profile_upload_unsigned";

      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await response.stream.bytesToString();
        final responseData = json.decode(res);
        return responseData['secure_url'];
      }
      return null;
    } catch (e) {
      print("Error uploading image to Cloudinary: $e");
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String imageUrl,
    required String name,
    required String about,
    required String phoneNumber,
  }) async {
    try {
      final userId = auth.currentUser!.uid;
      final previousImageUrl = currentUser.value.profileImage;
      const defaultImageUrl = AssetsImage.defaultPic;

      await db.collection('users').doc(userId).update({
        "profileImage": imageUrl,
        "name": name,
        "about": about,
        "phoneNumber": phoneNumber,
      });

      currentUser.value.name = name;
      currentUser.value.about = about;
      currentUser.value.profileImage = imageUrl;
      currentUser.value.phoneNumber = phoneNumber;

      if (previousImageUrl != null &&
          previousImageUrl.isNotEmpty &&
          previousImageUrl != defaultImageUrl) {
        await deleteImageFromCloudinary(previousImageUrl);
      }
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }

  Future<void> deleteImageFromCloudinary(String imageUrl) async {
    try {
      final url = Uri.parse("https://chatting-server-17pa.onrender.com/deleteImage");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'imageUrl': imageUrl}),
      );
      if (response.statusCode != 200) {
        print("Failed to delete image: ${response.body}");
      }
    } catch (e) {
      print("Error communicating with server to delete image: $e");
    }
  }

  String generateSignature(String publicId, String apiSecret) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signatureString = "public_id=$publicId&timestamp=$timestamp$apiSecret";
    return sha1.convert(utf8.encode(signatureString)).toString();
  }

  Future<void> signOut() async {
    try {
      // --- CRITICAL FIX: WIPE ISAR ON LOGOUT ---
      // This prevents Dragon from seeing Dhruv's local messages on the same device!
      if (Get.isRegistered<DBcontroller>()) {
        final dbController = Get.find<DBcontroller>();
        await dbController.isar.writeTxn(() async {
          await dbController.isar.localMessageModels.clear();
        });
      }
      // -----------------------------------------
      await auth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}