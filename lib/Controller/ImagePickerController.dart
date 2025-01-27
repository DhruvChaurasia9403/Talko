import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ImagePickerController extends GetxController {
  final String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dgsxsujn9/image/upload";
  final String uploadPreset = "profile_upload_unsigned";

  Future<String> pickImage() async {
    // Use the image_picker package to choose an image
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Upload to Cloudinary
      String imageUrl = await uploadImageToCloudinary(File(pickedFile.path));
      print("Image URL: $imageUrl");
      return imageUrl;
    }
    return "";
  }

  Future<String> uploadImageToCloudinary(File image) async {
    var uri = Uri.parse(cloudinaryUrl);
    var request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      // If the upload is successful, extract the image URL from the response
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      print(data['secure_url']);
      return data['secure_url']; // Cloudinary image URL
    } else {
      throw Exception('Failed to upload image');
    }
  }
}
