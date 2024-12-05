import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/SplashController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
class Splashpage extends StatelessWidget {
  const Splashpage({super.key});

  @override
  Widget build(BuildContext context) {
    SplashController splashController = Get.put(SplashController());
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(AssetsImage.appIconSVG),
      )
    );
  }
}
