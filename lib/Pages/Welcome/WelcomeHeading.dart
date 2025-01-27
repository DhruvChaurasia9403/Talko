import 'package:chatting/Config/Strings.dart';
import 'package:chatting/Config/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class welcomeHeading extends StatelessWidget {
  const welcomeHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            SvgPicture.asset(
                AssetsImage.appIconSVG
            ), 
          ],
        ),
        const SizedBox(height : 20),
        Text(AppStrings.appName,style:Theme.of(context).textTheme.headlineLarge?.copyWith(color:Theme.of(context).colorScheme.secondary)),
      ],
    );
  }
}
