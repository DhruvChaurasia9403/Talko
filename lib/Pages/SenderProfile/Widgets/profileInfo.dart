import 'package:chatting/Controller/ProfileController.dart';
import 'package:chatting/Pages/Chat/chatPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profileinfo extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String email;

  const Profileinfo({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.put(ProfileController());

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 400,
              fit: BoxFit.cover, // Ensures the image covers the area
            ),
          ),
          const SizedBox(height: 10),
          Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          Text(email, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 10),
                      Text("Call", style: Theme.of(context).textTheme.labelLarge),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.videocam, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10),
                      Text("Video", style: Theme.of(context).textTheme.labelLarge),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: InkWell(
                    onTap: (){
                      Get.back();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.chat),
                        const SizedBox(width: 10),
                        Text("Chat", style: Theme.of(context).textTheme.labelLarge),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
