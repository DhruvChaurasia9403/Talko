// File: Pages/Auth/SignUpForm.dart

import 'package:chatting/Controller/AuthController.dart';
import 'package:chatting/Widgets/PrimaryButton.dart';
import'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthSignUpForm extends StatelessWidget {
  const AuthSignUpForm({super.key});

  @override
  Widget build(BuildContext context) {

    TextEditingController name = TextEditingController();
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();

    AuthController authController = Get.put(AuthController());

    return  Column(
      children: [
        const SizedBox(height:15),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
              controller: name,
              decoration:InputDecoration(
                hintText: 'name'.tr, // <-- Changed
                hintStyle: Theme.of(context).textTheme.labelLarge,
                prefixIcon: Icon(Icons.person_outline,color: Theme.of(context).colorScheme.onPrimaryContainer),
              )
          ),
        ),
        const SizedBox(height:10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
              controller: email,
              decoration:InputDecoration(
                hintText: 'email'.tr, // <-- Changed
                hintStyle: Theme.of(context).textTheme.labelLarge,
                prefixIcon: Icon(Icons.alternate_email_outlined,color: Theme.of(context).colorScheme.onPrimaryContainer),
              )
          ),
        ),
        const SizedBox(height:10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
              obscureText: true,
              controller: password,
              decoration:InputDecoration(
                hintText: 'password'.tr, // <-- Changed
                hintStyle: Theme.of(context).textTheme.labelLarge,
                prefixIcon: Icon(Icons.password,color: Theme.of(context).colorScheme.onPrimaryContainer),
              )
          ),
        ),
        const SizedBox(height:20),
        Obx(() => authController.isLoading.value
            ?const CircularProgressIndicator()
            :Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Primarybutton(
                btnName: 'signUp'.tr, // <-- Changed
                icon:Icons.lock,
                onTap:(){
                  authController.createUser(email.text, password.text,name.text);
                }
            ),
          ],
        ),),
      ],
    );
  }
}