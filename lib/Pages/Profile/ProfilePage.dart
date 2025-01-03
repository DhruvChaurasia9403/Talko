import 'dart:io';

import 'package:chatting/Controller/ImagePickerController.dart';
import 'package:chatting/Controller/ProfileController.dart';
import 'package:chatting/Widgets/PrimaryButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final ImagePickerController imagePickerController = Get.put(ImagePickerController());
    final RxBool isEdit = false.obs;
    final RxString imagePath = "".obs;
    final RxBool isLoading = false.obs;

    // Function to update the profile image in Firebase
    Future<void> updateProfileImageInFirebase(String imageUrl) async {
      try {
        final String userId = profileController.currentUser.value?.id ?? "";
        if (userId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'profileImage': imageUrl});
          print('Profile image URL updated in Firestore');
        } else {
          print('Error: User ID is empty');
        }
      } catch (e) {
        print('Error updating profile image in Firebase: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.labelLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed:(){
              profileController.signOut();
              Get.offAllNamed('/loginPage');
            }
          )
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Get.offAllNamed('/homePage');
          },
        ),
      ),
      body: Obx(() {
        if (profileController.currentUser.value == null) {
          return Center(child: CircularProgressIndicator());
        }

        final currentUser = profileController.currentUser.value!;
        final TextEditingController name = TextEditingController(text: currentUser.name ?? "");
        final TextEditingController phone = TextEditingController(text: currentUser.phoneNumber ?? "");
        final TextEditingController about = TextEditingController(text: currentUser.about ?? "");

        return Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(() {
                              return isEdit.value
                                  ? InkWell(
                                onTap: () async {
                                  imagePath.value = await imagePickerController.pickImage();
                                  print("IMAGE PICKED : ${imagePath.value}");
                                },
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.background,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      width: 1,
                                    ),
                                  ),
                                  child: imagePath.value.isEmpty
                                      ? (currentUser.profileImage != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.network(
                                      currentUser.profileImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : Icon(Icons.add))
                                      : ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.network(
                                      imagePath.value,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                                  : Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.background,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    width: 1,
                                  ),
                                ),
                                child: currentUser.profileImage != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    currentUser.profileImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : Icon(Icons.image),
                              );
                            }),
                          ],
                        ),
                        Obx(
                              () => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: name,
                              style: Theme.of(context).textTheme.headlineSmall,
                              enabled: isEdit.value,
                              decoration: InputDecoration(
                                labelText: "Name",
                                filled: isEdit.value,
                                prefixIcon: Icon(Icons.person, color: Colors.white60),
                              ),
                            ),
                          ),
                        ),
                        Obx(
                              () => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: about,
                              style: Theme.of(context).textTheme.headlineSmall,
                              enabled: isEdit.value,
                              decoration: InputDecoration(
                                labelText: "About",
                                filled: isEdit.value,
                                prefixIcon: Icon(Icons.info, color: Colors.white60),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white60),
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: "Email",
                              fillColor: Theme.of(context).colorScheme.primaryContainer,
                              prefixIcon: Icon(Icons.alternate_email, color: Colors.white60),
                            ),
                          ),
                        ),
                        Obx(
                              () => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: phone,
                              style: Theme.of(context).textTheme.headlineSmall,
                              enabled: isEdit.value,
                              decoration: InputDecoration(
                                labelText: "Phone Number",
                                filled: isEdit.value,
                                prefixIcon: Icon(Icons.phone, color: Colors.white60),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 50),
                        Obx(
                              () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isEdit.value
                                  ? Primarybutton(
                                btnName: "Save",
                                icon: Icons.save,
                                onTap: () async {
                                  isLoading.value = true;
                                  isEdit.value = false;
                                  if (imagePath.value.isNotEmpty) {
                                    await updateProfileImageInFirebase(imagePath.value);
                                  }
                                  await profileController.updateUserProfile(
                                    imageUrl: imagePath.value.isNotEmpty
                                        ? imagePath.value
                                        : currentUser.profileImage!,
                                    name: name.text,
                                    about: about.text,
                                    phoneNumber: phone.text,
                                  );
                                  isLoading.value = false;
                                  print("Profile details saved successfully.");
                                },
                              )
                                  : Primarybutton(
                                btnName: "Edit",
                                icon: Icons.edit,
                                onTap: () {
                                  isEdit.value = true;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Obx(() {
                          return isLoading.value ? CircularProgressIndicator() : SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}