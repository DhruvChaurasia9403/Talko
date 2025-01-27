import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:chatting/Pages/Chat/Widgets/MessagesStatus.dart';
import 'package:chatting/Pages/Chat/Widgets/SenderChat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Model/ChatModel.dart';

class chatPage extends StatelessWidget {
  final UserModel userModel;
  const chatPage({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.put(ChatController());
    TextEditingController messageController = TextEditingController();
    ChatModel chatModel = ChatModel();


    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam),
          )
        ],
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: Image.asset(AssetsImage.boyPic),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userModel.name ?? "Unknown",
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    userModel.status ?? "Offline",
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Theme.of(context).colorScheme.onPrimaryContainer),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Row(
          children: [
            IconButton(
              icon: SvgPicture.asset(AssetsImage.micSVG, width: 25),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  filled: false,
                  hintText: "Type message ...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(AssetsImage.gallerySVG),
              onPressed: () {},
            ),
            IconButton(
              icon: SvgPicture.asset(AssetsImage.sendSVG),
              onPressed: () {
                if (messageController.text.trim().isNotEmpty) {

                  chatController.sendMessage(userModel.id!, messageController.text.trim());
                  messageController.clear();
                }
              },
            ),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(bottom: 70),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: StreamBuilder<List<ChatModel>>(
            stream: chatController.getMessages(userModel.id!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text("An error occurred. Please try again."),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No messages found."),
                );
              } else {
                final messages = snapshot.data!;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return SenderChat(
                      sms: message.message,
                      isComing: message.senderId != userModel.id,
                      status: MessageStatus.values.firstWhere(
                            (e) => e.toString() == 'MessageStatus.${message.readStatus}',
                        orElse: () => MessageStatus.unknown,
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}