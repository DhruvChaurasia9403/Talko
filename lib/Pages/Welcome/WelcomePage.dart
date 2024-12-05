import 'package:chatting/Config/Strings.dart';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Pages/Welcome/WelcomeBody.dart';
import 'package:chatting/Pages/Welcome/WelcomeFooter.dart';
import 'package:chatting/Pages/Welcome/WelcomeHeading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:slide_to_act/slide_to_act.dart';
class Welcomepage extends StatelessWidget {
  const Welcomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: welcomeHeading(),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Welcomebody(),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Welcomefooter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}