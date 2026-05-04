// File: Controller/ImagePickerController.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class ImagePickerController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // This state allows us to show a loading spinner on the UI
  RxBool isUploading = false.obs;

  Future<String?> pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) return await _uploadToCloudinary(image.path, "image");
    return null;
  }

  Future<String?> pickAndUploadVideo() async {
    // Compress video by setting a max duration
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 3));
    if (video != null) return await _uploadToCloudinary(video.path, "video");
    return null;
  }

  Future<String?> _uploadToCloudinary(String filePath, String resourceType) async {
    isUploading.value = true;
    try {
      // Your specific Cloudinary credentials
      String cloudName = "dgsxsujn9";
      String uploadPreset = "sampark_preset"; // Must match the preset you created

      var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload");
      var request = http.MultipartRequest("POST", uri);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var result = json.decode(String.fromCharCodes(responseData));
        return result['secure_url']; // Returns the live URL of the image/video
      } else {
        print("Cloudinary Upload Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e");
    } finally {
      isUploading.value = false;
    }
    return null;
  }
}