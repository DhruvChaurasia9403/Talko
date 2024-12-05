import 'package:chatting/Pages/Auth/AuthCard.dart';
import 'package:chatting/Pages/Welcome/WelcomeHeading.dart';
import 'package:flutter/material.dart';
class Authpage extends StatelessWidget {
  const Authpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const welcomeHeading(),
                const SizedBox(height:70),
                AuthCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
