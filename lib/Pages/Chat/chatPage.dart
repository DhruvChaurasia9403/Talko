// File: Pages/Chat/chatPage.dart

import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Controller/ProfileController.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:chatting/Pages/Chat/Widgets/MessagesStatus.dart';
import 'package:chatting/Pages/Chat/Widgets/SenderChat.dart';
import 'package:chatting/Pages/SenderProfile/senderProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Model/ChatModel.dart';
import '../../Model/ChatRoomModel.dart';

class chatPage extends StatefulWidget {
  final UserModel userModel;
  const chatPage({super.key, required this.userModel});

  @override
  _chatPageState createState() => _chatPageState();
}

class _chatPageState extends State<chatPage> {
  final ScrollController _scrollController = ScrollController();
  late ChatController chatController;
  late ProfileController profileController;
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();
    profileController = Get.put(ProfileController());
    _resetUnreadCount();
  }
  Future<void> _resetUnreadCount() async {
    try {
      String roomId = chatController.getRoomId(widget.userModel.id!);
      final roomRef = profileController.db.collection("chats").doc(roomId);
      final doc = await roomRef.get();

      if (doc.exists) {
        ChatRoomModel room = ChatRoomModel.fromJson(doc.data()!);

        // This is the important logic:
        // We only reset the count if the *current user* is the one
        // who received the last message.
        if (room.receiver?.id == profileController.auth.currentUser!.uid) {
          await roomRef.update({'unReadMessageNo': '0'});
          print("Unread count reset to 0.");
        } else {
          // This is normal. It just means the current user was the *sender*
          // of the last message, so there was no count for them to reset.
          print("No unread count to reset for this user.");
        }
      }
    } catch (e) {
      print("Error in _resetUnreadCount: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.background,
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
        title: InkWell(
          onTap: () {
            Get.to(SenderProfilePage(userModel: widget.userModel));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.network(
                    widget.userModel.profileImage ?? AssetsImage.defaultPic,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userModel.name ?? 'chatUnknownUser'.tr, // <-- Changed
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: profileController.db.collection('users').doc(widget.userModel.id).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            'chatLoading'.tr, // <-- Changed
                            style: Theme.of(context).textTheme.labelLarge,
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'chatError'.tr, // <-- Changed
                            style: Theme.of(context).textTheme.labelLarge,
                          );
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Text(
                            'chatOffline'.tr, // <-- Changed
                            style: Theme.of(context).textTheme.labelLarge,
                          );
                        }
                        var userData = snapshot.data!.data() as Map<String, dynamic>;
                        return Text(
                          userData['status'] ?? 'chatOffline'.tr, // <-- Changed
                          style: Theme.of(context).textTheme.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                decoration: InputDecoration(
                  filled: false,
                  hintText: 'chatTypeMessage'.tr, // <-- Changed
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
                  chatController.sendMessage(widget.userModel.id!, messageController.text.trim(), widget.userModel);
                  messageController.clear();
                  _scrollToBottom();
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
            stream: chatController.getMessages(widget.userModel.id!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('chatErrorOccurred'.tr), // <-- Changed
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('chatNoMessages'.tr), // <-- Changed
                );
              } else {
                final messages = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    if (message.senderId != profileController.currentUser.value.id) {
                      chatController.updateMessageReadStatus(chatController.getRoomId(widget.userModel.id!), message.id!);
                    }
                    return SenderChat(
                      sms: message.message,
                      isComing: message.senderId != profileController.currentUser.value.id,
                      status: MessageStatus.values.firstWhere(
                            (e) => e.toString() == 'MessageStatus.${message.readStatus}',
                        orElse: () => MessageStatus.unknown,
                      ),
                      timestamp: message.timestamp,
                      index: index,
                      messageId: message.id!,
                      senderId: message.senderId!,
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