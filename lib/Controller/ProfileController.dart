import 'dart:io';
import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON parsing

class ProfileController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  Rx<UserModel> currentUser = UserModel().obs;

  @override
  void onInit() async {
    super.onInit();
    print("Initializing ProfileController...");
    if (auth.currentUser != null) {
      print("Authenticated User: ${auth.currentUser!.uid}");
      await getUserDetails(); // Ensure this completes before proceeding
    } else {
      print("User not authenticated.");
    }
  }




  // Fetch user details from Firestore
  Future<void> getUserDetails() async {
    try {
      print("Fetching user details...");
      DocumentSnapshot<Map<String, dynamic>> userDoc = await db
          .collection('users')
          .doc(auth.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        print("User data: ${userDoc.data()}"); // Debug: Check fetched data
        currentUser.value = UserModel.fromJson(userDoc.data()!);
      } else {
        print("No document found for the user.");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }






  // Upload Image to Cloudinary and return the image URL
  Future<String?> uploadImageToCloudinary(String imagePath) async {
    try {
      const cloudName = "dgsxsujn9"; // Replace with your Cloudinary cloud name
      const uploadPreset = "profile_upload_unsigned";

      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await response.stream.bytesToString();
        final responseData = json.decode(res); // Parse the JSON response
        return responseData['secure_url']; // Extract and return the URL
      } else {
        print("Image upload failed: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Error uploading image to Cloudinary: $e");
      return null;
    }
  }


  // Update user profile in Firebase
  Future<void> updateUserProfile({required String imageUrl, required String name, required String about, required String phoneNumber}) async {
    try {
      final userId = auth.currentUser!.uid;
      await db.collection('users').doc(userId).update({
        "profileImage": imageUrl,
        "name": name,
        "about": about,
        "phoneNumber": phoneNumber,
      });

      // Update local state
      currentUser.value.name = name;
      currentUser.value.about = about;
      currentUser.value.profileImage = imageUrl;
      currentUser.value.phoneNumber = phoneNumber;
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }
}
