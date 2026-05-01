// File: Pages/Chat/chatPage.dart

import 'dart:async';
import 'dart:ui';
import 'package:chatting/Pages/Chat/Widgets/TypingIndicator.dart';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Controller/ProfileController.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:chatting/Pages/Chat/Widgets/MessagesStatus.dart';
import 'package:chatting/Pages/Chat/Widgets/SenderChat.dart';
import 'package:chatting/Pages/SenderProfile/senderProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();
    profileController = Get.find<ProfileController>();
    chatController.clearSelection(); // Clear any phantom selections on load
    _resetUnreadCount();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    chatController.updateTypingStatus(widget.userModel.id!, false);
    chatController.clearSelection();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty) {
      chatController.updateTypingStatus(widget.userModel.id!, true);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        chatController.updateTypingStatus(widget.userModel.id!, false);
      });
    } else {
      chatController.updateTypingStatus(widget.userModel.id!, false);
    }
  }

  Future<void> _resetUnreadCount() async {
    try {
      String roomId = chatController.getRoomId(widget.userModel.id!);
      final roomRef = profileController.db.collection("chats").doc(roomId);
      final doc = await roomRef.get();

      if (doc.exists) {
        ChatRoomModel room = ChatRoomModel.fromJson(doc.data()!);
        if (room.receiver?.id == profileController.auth.currentUser!.uid) {
          await roomRef.update({'unReadMessageNo': '0'});
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _copySelectedMessages() {
    // Collect all selected message texts (you could extend this logic)
    Clipboard.setData(const ClipboardData(text: "Selected messages copied."));
    Get.snackbar("Copied", "Messages copied to clipboard", snackPosition: SnackPosition.TOP);
    chatController.clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (chatController.selectedMessageIds.isNotEmpty) {
          chatController.clearSelection();
          return false; // Don't pop, just clear selection
        }
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Obx(() {
                // --- REACTIVE APP BAR ---
                if (chatController.selectedMessageIds.isNotEmpty) {
                  return AppBar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.9),
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => chatController.clearSelection(),
                    ),
                    title: Text(
                      "${chatController.selectedMessageIds.length} Selected",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        onPressed: _copySelectedMessages,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        onPressed: () {
                          chatController.deleteSelectedMessages(widget.userModel.id!);
                        },
                      ),
                    ],
                  );
                }

                // Standard AppBar
                return AppBar(
                  backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  elevation: 0,
                  actions: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.phone_outlined)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.videocam_outlined)),
                    const SizedBox(width: 8),
                  ],
                  leading: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  title: InkWell(
                    onTap: () => Get.to(() => SenderProfilePage(userModel: widget.userModel)),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'profile_${widget.userModel.id}',
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                widget.userModel.profileImage ?? AssetsImage.defaultPic,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.userModel.name ?? 'chatUnknownUser'.tr,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                stream: profileController.db.collection('users').doc(widget.userModel.id).snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || !snapshot.data!.exists) {
                                    return const SizedBox.shrink();
                                  }
                                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                                  bool isOnline = userData['status'] == 'online';
                                  return Row(
                                    children: [
                                      if (isOnline)
                                        Container(
                                          margin: const EdgeInsets.only(right: 4),
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.greenAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      Text(
                                        userData['status'] ?? 'chatOffline'.tr,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: isOnline ? Colors.greenAccent : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 80),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<ChatModel>>(
                      stream: chatController.getMessages(widget.userModel.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                          return Center(child: Text('chatNoMessages'.tr));
                        } else {
                          final messages = snapshot.data!;

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                            chatController.fetchSmartReplies(messages);
                          });

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 100, left: 10, right: 10),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              if (message.senderId != profileController.currentUser.value.id && message.readStatus != 'read') {
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

                  // Typing Indicator
                  StreamBuilder<bool>(
                    stream: chatController.getTypingStatus(widget.userModel.id!),
                    builder: (context, snapshot) {
                      bool isTyping = snapshot.data ?? false;
                      if (isTyping) {
                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(left: 14, bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                bottomLeft: Radius.circular(5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Typing",
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TypingIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                  dotSize: 5.0,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Obx(() {
                    if (chatController.smartReplies.isEmpty && !chatController.isFetchingReplies.value) {
                      return const SizedBox.shrink();
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: chatController.isFetchingReplies.value
                            ? [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 8),
                            child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)
                            ),
                          )
                        ]
                            : chatController.smartReplies.map((reply) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                            child: InkWell(
                              onTap: () {
                                chatController.sendMessage(widget.userModel.id!, reply, widget.userModel);
                                chatController.smartReplies.clear();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.auto_awesome, size: 14, color: Theme.of(context).colorScheme.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      reply,
                                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),

                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
                                onPressed: () {},
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: TextField(
                                    controller: messageController,
                                    onChanged: _onTextChanged,
                                    maxLines: 4,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      hintText: 'Message...',
                                      hintStyle: TextStyle(color: Colors.grey.shade500),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: SvgPicture.asset(AssetsImage.sendSVG, color: Colors.black87, width: 20),
                                  onPressed: () {
                                    if (messageController.text.trim().isNotEmpty) {
                                      chatController.sendMessage(widget.userModel.id!, messageController.text.trim(), widget.userModel);
                                      messageController.clear();
                                      chatController.updateTypingStatus(widget.userModel.id!, false);
                                      _typingTimer?.cancel();
                                      _scrollToBottom();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}