import 'dart:ui';
import 'package:chatting/AI/Model/chat_message_model.dart';
import 'package:chatting/AI/bloc/chat_bloc.dart';
import '../../../../Controller/ThemeController.dart'; // Adjust depth as needed
import 'package:chatting/Widgets/PremiumSurface.dart';
import 'package:chatting/Widgets/AmbientBackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CreatePromptScreen extends StatefulWidget {
  const CreatePromptScreen({super.key});

  @override
  State<CreatePromptScreen> createState() => _CreatePromptScreenState();
}

class _CreatePromptScreenState extends State<CreatePromptScreen> with WidgetsBindingObserver {
  TextEditingController textEditingController = TextEditingController();
  final ChatBloc chatBloc = ChatBloc();
  final ThemeController themeController = Get.find<ThemeController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, "/homePage");
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: PremiumSurface(
              borderRadius: 0,
              child: SafeArea(
                bottom: false,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Obx(() => IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: themeController.text),
                    onPressed: () => Navigator.pushReplacementNamed(context, "/homePage"),
                  )),
                  title: Obx(() => Text(
                    "V.O.I.D. SYSTEM",
                    style: TextStyle(color: themeController.primary, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                  )),
                  centerTitle: true,
                ),
              ),
            ),
          ),
          body: BlocConsumer<ChatBloc, ChatState>(
            bloc: chatBloc,
            listener: (context, state) {
              if (state is ChatSuccessState) {
                _scrollToBottom();
              }
            },
            builder: (context, state) {
              List<ChatMessageModel> message = [];
              if (state is ChatSuccessState) {
                message = state.messages;
              }

              return Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
                            itemCount: message.length,
                            itemBuilder: (context, index) {
                              bool isUserMessage = message[index].role == 'user';

                              return Obx(() {
                                Color bubbleColor = isUserMessage ? themeController.primary : themeController.surface;
                                Color fontColor = isUserMessage ? Colors.white : themeController.text;

                                BorderRadius bubbleRadius = BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: isUserMessage ? const Radius.circular(20) : const Radius.circular(5),
                                  bottomRight: isUserMessage ? const Radius.circular(5) : const Radius.circular(20),
                                );

                                Widget content = AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: themeController.isGlass ? bubbleColor.withAlpha(isUserMessage ? 220 : 150) : bubbleColor,
                                    borderRadius: bubbleRadius,
                                    border: themeController.isGlass
                                        ? Border.all(color: Colors.white.withAlpha(themeController.isDark ? 20 : 100), width: 1)
                                        : null,
                                    boxShadow: themeController.isGlass ? null : [
                                      BoxShadow(color: themeController.isDark ? Colors.black.withAlpha(150) : Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(2, 4))
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                                    child: Text(message[index].parts[0].text, style: TextStyle(color: fontColor, fontSize: 16, height: 1.4)),
                                  ),
                                );

                                return Align(
                                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                                  child: themeController.isGlass
                                      ? ClipRRect(
                                    borderRadius: bubbleRadius,
                                    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), child: content),
                                  )
                                      : content,
                                );
                              });
                            },
                          ),
                        ),
                        if (chatBloc.generating)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                SizedBox(height: 40, width: 40, child: Lottie.asset('assets/loader.json')),
                                const SizedBox(width: 15),
                                Obx(() => Text("V.O.I.D. is processing...", style: TextStyle(color: themeController.primary))),
                              ],
                            ),
                          ),

                        // Input Console
                        PremiumSurface(
                          borderRadius: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Obx(() => Container(
                                  decoration: BoxDecoration(
                                    color: themeController.surface.withAlpha(themeController.isGlass ? 150 : 255),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: themeController.primary.withAlpha(50)),
                                  ),
                                  child: TextField(
                                    controller: textEditingController,
                                    style: TextStyle(color: themeController.text),
                                    cursorColor: themeController.primary,
                                    maxLines: 4,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      hintText: "Initialize prompt...",
                                      hintStyle: TextStyle(color: themeController.subText),
                                      border: InputBorder.none,
                                      fillColor: Colors.transparent,
                                    ),
                                  ),
                                )),
                              ),
                              const SizedBox(width: 12),
                              Obx(() => Container(
                                decoration: BoxDecoration(
                                    color: themeController.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: themeController.isGlass ? [] : [
                                      BoxShadow(color: themeController.primary.withAlpha(100), blurRadius: 10, offset: const Offset(0, 4))
                                    ]
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.send, color: Colors.white),
                                  onPressed: () {
                                    if (textEditingController.text.trim().isNotEmpty) {
                                      chatBloc.add(ChatGenerateNewTextMessageEvent(inputMessage: textEditingController.text));
                                      textEditingController.clear();
                                      _scrollToBottom();
                                    }
                                  },
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}