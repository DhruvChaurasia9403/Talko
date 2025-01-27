import 'package:chatting/Controller/AuthController.dart';
import 'package:chatting/Widgets/PrimaryButton.dart';
import'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthLoginForm extends StatelessWidget {
  AuthLoginForm({super.key});

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  AuthController authController = Get.put(AuthController());


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height:20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: email,
            decoration:InputDecoration(
              hintText: "Email",
              hintStyle: Theme.of(context).textTheme.labelLarge,
              prefixIcon: Icon(Icons.alternate_email_outlined,color: Theme.of(context).colorScheme.onPrimaryContainer),
            )
          ),
        ),
        const SizedBox(height:10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: password,
            decoration:InputDecoration(
              hintText: "Password",
              hintStyle: Theme.of(context).textTheme.labelLarge,
              prefixIcon: Icon(Icons.password,color: Theme.of(context).colorScheme.onPrimaryContainer),
            )
          ),
        ),
        const SizedBox(height:89),
        Obx(()=>authController.isLoading.value
            ? const CircularProgressIndicator()
            :Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Primarybutton(
                btnName:"Login",
                icon:Icons.lock,
                onTap:(){
                  authController.login(
                      email.text,
                      password.text
                  );
                  //Get.offAllNamed("/homePage");
                }
            ),
          ],
        ),),
      ],
    );
  }
}
