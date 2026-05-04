// File: Pages/Chat/chatPage.dart

import 'dart:async';
import 'dart:ui';
import 'package:chatting/Pages/Chat/Widgets/TypingIndicator.dart';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Controller/DBController.dart';
import 'package:chatting/Controller/ImagePickerController.dart';
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
import 'package:isar/isar.dart';
import '../../Model/ChatModel.dart';
import '../../Model/ChatRoomModel.dart';
import '../../Model/LocalMessageModel.dart';

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
  late ImagePickerController imagePickerController;
  final TextEditingController messageController = TextEditingController();
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();
    profileController = Get.put(ProfileController());
    imagePickerController = Get.put(ImagePickerController());
    chatController.clearSelection();
    chatController.resetMessageLimit();
    _resetUnreadCount();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.minScrollExtent) {
        chatController.loadMoreMessages();
        HapticFeedback.lightImpact();
      }
    });
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

      if (doc.exists && doc.data() != null) {
        ChatRoomModel room = ChatRoomModel.fromJson(doc.data()!);
        if (room.lastMessageSenderId != profileController.auth.currentUser!.uid) {
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

  void _showAttachmentMenu() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _attachmentIcon(Icons.image, "Photo", Colors.purpleAccent, () async {
                          Navigator.pop(context);
                          String? url = await imagePickerController.pickAndUploadImage();
                          if (url != null) {
                            chatController.sendMessage(widget.userModel.id!, "", widget.userModel, imageUrl: url);
                          }
                        }),
                        _attachmentIcon(Icons.videocam, "Video", Colors.orangeAccent, () async {
                          Navigator.pop(context);
                          String? url = await imagePickerController.pickAndUploadVideo();
                          if (url != null) {
                            chatController.sendMessage(widget.userModel.id!, "", widget.userModel, imageUrl: url);
                          }
                        }),
                        _attachmentIcon(Icons.gif_box, "GIF", Colors.greenAccent, () {
                          Navigator.pop(context);
                          chatController.sendMessage(widget.userModel.id!, "", widget.userModel, imageUrl: "https://media.giphy.com/media/l41YkxvU8c7J7Bba0/giphy.gif");
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  Widget _attachmentIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (chatController.selectedMessageIds.isNotEmpty) {
          chatController.clearSelection();
          return false;
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
                        onPressed: () async {
                          final dbC = Get.find<DBcontroller>();
                          var selectedLocal = await dbC.isar.localMessageModels
                              .filter()
                              .anyOf(chatController.selectedMessageIds, (q, String id) => q.firestoreMessageIdEqualTo(id))
                              .findAll();

                          String copyText = selectedLocal.map((m) => m.message).join('\n\n');

                          if(copyText.isNotEmpty){
                            Clipboard.setData(ClipboardData(text: copyText));
                            Get.snackbar("Copied", "Text saved to clipboard");
                          }
                          chatController.clearSelection();
                        },
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
                                widget.userModel.name ?? 'Unknown',
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
                                        userData['status'] ?? 'Offline',
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
                        }

                        if (snapshot.hasError) {
                          print("STREAM ERROR: ${snapshot.error}");
                          return const Center(child: Text('Data Error', style: TextStyle(color: Colors.redAccent)));
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 50, color: Colors.white.withOpacity(0.2)),
                                const SizedBox(height: 16),
                                Text('No messages yet', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                              ],
                            ),
                          );
                        }

                        final messages = snapshot.data!;

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                          chatController.fetchSmartReplies(messages);
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 100, left: 10, right: 10, bottom: 20),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final String msgId = message.id ?? "";
                            final String msgSenderId = message.senderId ?? "unknown";
                            final String myId = profileController.currentUser.value.id ?? "unknown";

                            if (msgId.isNotEmpty && msgSenderId != myId && message.readStatus != 'read') {
                              chatController.updateMessageReadStatus(
                                  chatController.getRoomId(widget.userModel.id!),
                                  msgId
                              );
                            }

                            return SenderChat(
                              sms: message.message,
                              isComing: msgSenderId != myId,
                              status: MessageStatus.values.firstWhere(
                                    (e) => e.toString() == 'MessageStatus.${message.readStatus}',
                                orElse: () => MessageStatus.unknown,
                              ),
                              timestamp: message.timestamp,
                              index: index,
                              messageId: msgId.isEmpty ? "unknown_$index" : msgId,
                              senderId: msgSenderId,
                              imageUrl: message.imageUrl,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // --- NEW: V.O.I.D. TYPING SPINNER ---
                  Obx(() {
                    if (chatController.isVoidTyping.value) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(left: 14, bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
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
                              Icon(Icons.smart_toy, size: 14, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text("V.O.I.D. is thinking...", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
                              const SizedBox(width: 10),
                              SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  // ------------------------------------

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

                  // Image Uploading Indicator
                  Obx(() {
                    if (imagePickerController.isUploading.value) {
                      return Container(
                        margin: const EdgeInsets.only(left: 10, bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
                            const SizedBox(width: 10),
                            const Text("Uploading media...", style: TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

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
                                onPressed: _showAttachmentMenu,
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