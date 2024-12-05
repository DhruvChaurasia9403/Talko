import 'package:flutter/material.dart';

class Primarybutton extends StatelessWidget {
  final String btnName;
  final IconData icon;
  final VoidCallback onTap;
  const Primarybutton({super.key,required this.btnName , required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap:onTap,
          child: Container(
            padding:const EdgeInsets.symmetric(horizontal: 40,vertical: 15),
            decoration: BoxDecoration(
              color:Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login_outlined),
                const SizedBox(width:10),
                Text(btnName,style:Theme.of(context).textTheme.bodyLarge),
              ],
            )
          ),
        ),
      ],
    );
  }
}
