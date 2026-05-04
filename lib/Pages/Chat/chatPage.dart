import 'dart:async';
import 'dart:ui';
import '../../Controller/ThemeController.dart';
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
import '../../Widgets/PremiumSurface.dart';
import '../../Widgets/AmbientBackground.dart';

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
          // <-- CHANGE '0' to 0
          await roomRef.update({'unReadMessageNo': 0});
        }
      }
    } catch (e) {
      debugPrint("Error in _resetUnreadCount: $e");
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
    final themeController = Get.find<ThemeController>();
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return PremiumSurface(
            borderRadius: 30,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5, width: 40,
                  decoration: BoxDecoration(
                    color: themeController.subText.withAlpha(100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _attachmentIcon(Icons.image, "Photo", themeController.primary, () async {
                      Navigator.pop(context);
                      String? url = await imagePickerController.pickAndUploadImage();
                      if (url != null) chatController.sendMessage(widget.userModel.id!, "", widget.userModel, imageUrl: url);
                    }),
                    _attachmentIcon(Icons.videocam, "Video", Colors.orangeAccent, () async {
                      Navigator.pop(context);
                      String? url = await imagePickerController.pickAndUploadVideo();
                      if (url != null) chatController.sendMessage(widget.userModel.id!, "", widget.userModel, imageUrl: url);
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
              color: color.withAlpha(30),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(100)),
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
    final themeController = Get.find<ThemeController>();

    return AmbientBackground(
      child: WillPopScope(
        onWillPop: () async {
          if (chatController.selectedMessageIds.isNotEmpty) {
            chatController.clearSelection();
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.transparent, // Show orbs
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: PremiumSurface(
              borderRadius: 0,
              child: Obx(() {
                if (chatController.selectedMessageIds.isNotEmpty) {
                  return AppBar(
                    backgroundColor: themeController.primary.withAlpha(50),
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.close, color: themeController.text),
                      onPressed: () => chatController.clearSelection(),
                    ),
                    title: Text(
                      "${chatController.selectedMessageIds.length} Selected",
                      style: TextStyle(color: themeController.text, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.copy, color: themeController.text),
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
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => chatController.deleteSelectedMessages(widget.userModel.id!),
                      ),
                    ],
                  );
                }

                return AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    IconButton(onPressed: () {}, icon: Icon(Icons.phone_outlined, color: themeController.text)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.videocam_outlined, color: themeController.text)),
                    const SizedBox(width: 8),
                  ],
                  leading: IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_ios_new, size: 20, color: themeController.text),
                  ),
                  title: InkWell(
                    onTap: () => Get.to(() => SenderProfilePage(userModel: widget.userModel)),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'profile_${widget.userModel.id}',
                          child: Container(
                            height: 40, width: 40,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: themeController.primary.withAlpha(100))),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(widget.userModel.profileImage ?? AssetsImage.defaultPic, fit: BoxFit.cover),
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
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16, color: themeController.text),
                                overflow: TextOverflow.ellipsis,
                              ),
                              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                stream: profileController.db.collection('users').doc(widget.userModel.id).snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
                                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                                  bool isOnline = userData['status'] == 'online';
                                  return Row(
                                    children: [
                                      if (isOnline)
                                        Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          width: 8, height: 8,
                                          decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              shape: BoxShape.circle,
                                              boxShadow: [BoxShadow(color: Colors.greenAccent.withAlpha(100), blurRadius: 4)]
                                          ),
                                        ),
                                      Text(
                                        userData['status'] ?? 'Offline',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: isOnline ? Colors.greenAccent : themeController.subText,
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
          body: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 90),
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<ChatModel>>(
                        stream: chatController.getMessages(widget.userModel.id!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(color: themeController.primary));
                          }
                          if (snapshot.hasError) {
                            return const Center(child: Text('Data Error', style: TextStyle(color: Colors.redAccent)));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline, size: 50, color: themeController.subText.withAlpha(50)),
                                  const SizedBox(height: 16),
                                  Obx(() => Text('No messages yet', style: TextStyle(color: themeController.subText))),
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
                                chatController.updateMessageReadStatus(chatController.getRoomId(widget.userModel.id!), msgId);
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

                    // V.O.I.D. TYPING SPINNER
                    Obx(() {
                      if (chatController.isVoidTyping.value) {
                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(left: 14, bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: themeController.surface,
                              border: Border.all(color: themeController.primary.withAlpha(125)),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20), topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20), bottomLeft: Radius.circular(5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.smart_toy, size: 14, color: themeController.primary),
                                const SizedBox(width: 8),
                                Text("V.O.I.D. is thinking...", style: TextStyle(color: themeController.primary, fontSize: 12)),
                                const SizedBox(width: 10),
                                SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2, color: themeController.primary)),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // HUMAN TYPING INDICATOR
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
                                color: themeController.surface,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20), topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20), bottomLeft: Radius.circular(5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Typing", style: TextStyle(color: themeController.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  TypingIndicator(color: themeController.primary, dotSize: 5.0),
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

              // --- BOTTOM INPUT CONSOLE ---
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Uploading indicator
                    Obx(() {
                      if (imagePickerController.isUploading.value) {
                        return Container(
                          margin: const EdgeInsets.only(left: 10, bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: themeController.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: themeController.primary.withAlpha(125)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: themeController.primary)),
                              const SizedBox(width: 10),
                              Text("Uploading media...", style: TextStyle(fontSize: 12, color: themeController.text)),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // Smart Replies
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
                              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: themeController.primary)),
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
                                      color: themeController.surface.withAlpha(230),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: themeController.primary.withAlpha(125)),
                                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 4, offset: const Offset(0, 2))]
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.auto_awesome, size: 14, color: themeController.primary),
                                      const SizedBox(width: 6),
                                      Text(reply, style: TextStyle(color: themeController.text, fontSize: 13, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),

                    // Input Bar via PremiumSurface
                    PremiumSurface(
                      borderRadius: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Obx(() => IconButton(
                              icon: Icon(Icons.add_circle_outline, color: themeController.subText, size: 28),
                              onPressed: _showAttachmentMenu,
                            )),
                            Expanded(
                              child: Obx(() => Container(
                                decoration: BoxDecoration(
                                  color: themeController.surface.withAlpha(themeController.isGlass ? 150 : 255),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: themeController.primary.withAlpha(30)),
                                ),
                                child: TextField(
                                  controller: messageController,
                                  onChanged: _onTextChanged,
                                  maxLines: 4,
                                  minLines: 1,
                                  style: TextStyle(color: themeController.text),
                                  decoration: InputDecoration(
                                    hintText: 'Message...',
                                    hintStyle: TextStyle(color: themeController.subText.withAlpha(150)),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                ),
                              )),
                            ),
                            const SizedBox(width: 8),
                            Obx(() => Container(
                              decoration: BoxDecoration(
                                  color: themeController.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: themeController.isGlass ? [] : [
                                    BoxShadow(color: themeController.primary.withAlpha(100), blurRadius: 10, offset: const Offset(0, 4))
                                  ]
                              ),
                              child: IconButton(
                                icon: SvgPicture.asset(AssetsImage.sendSVG, color: Colors.white, width: 20),
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
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}