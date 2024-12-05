import 'package:chatting/Config/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';
class Welcomefooter extends StatelessWidget {
  const Welcomefooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
       children: [
         SlideAction(
           onSubmit: (){
             Get.offAllNamed("/authPage");
           },
           sliderRotate: true,
           innerColor: Theme.of(context).colorScheme.secondary,
           outerColor: Theme.of(context).colorScheme.onPrimaryContainer,
           sliderButtonIconSize: 25,
           sliderButtonIcon: SvgPicture.asset(AssetsImage.plugSVG),
         )
       ],
    );
  }
}
