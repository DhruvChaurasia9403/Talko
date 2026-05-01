// File: AI/Features/Prompt/UI/create_prompt.dart

import 'dart:ui';
import 'package:chatting/AI/Model/chat_message_model.dart';
import 'package:chatting/AI/bloc/chat_bloc.dart';
import 'package:chatting/Config/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class CreatePromptScreen extends StatefulWidget {
  const CreatePromptScreen({super.key});

  @override
  State<CreatePromptScreen> createState() => _CreatePromptScreenState();
}

class _CreatePromptScreenState extends State<CreatePromptScreen> with WidgetsBindingObserver {
  TextEditingController textEditingController = TextEditingController();
  final ChatBloc chatBloc = ChatBloc();
  bool _isKeyboardVisible = false;
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

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0;
    });
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, "/homePage");
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, "/homePage"),
          ),
          title: const Text(
            "V.O.I.D. SYSTEM",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          centerTitle: true,
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
                // Background Image
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AssetsImage.aiEarth),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Dynamic Blur Overlay
                BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: _isKeyboardVisible ? 10.0 : 4.0,
                      sigmaY: _isKeyboardVisible ? 10.0 : 4.0
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(_isKeyboardVisible ? 0.6 : 0.4),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          itemCount: message.length,
                          itemBuilder: (context, index) {
                            bool isUserMessage = message[index].role == 'user';
                            return Align(
                              alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                                ),
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: isUserMessage ? const Radius.circular(20) : const Radius.circular(5),
                                    bottomRight: isUserMessage ? const Radius.circular(5) : const Radius.circular(20),
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isUserMessage
                                            ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                                            : Colors.white.withOpacity(0.15),
                                        border: Border.all(
                                          color: isUserMessage ? Colors.transparent : Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                                      child: Text(
                                        message[index].parts[0].text,
                                        style: TextStyle(
                                          color: isUserMessage ? Colors.black87 : Colors.white,
                                          fontSize: 16,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
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
                              Text("V.O.I.D. is processing...", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                            ],
                          ),
                        ),
                      // Sci-Fi Input Console
                      ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: textEditingController,
                                    style: const TextStyle(color: Colors.white),
                                    cursorColor: Theme.of(context).colorScheme.primary,
                                    maxLines: 4,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      hintText: "Initialize prompt...",
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                      fillColor: Colors.white.withOpacity(0.1),
                                      filled: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        )
                                      ]
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.send, color: Colors.black87),
                                    onPressed: () {
                                      if (textEditingController.text.trim().isNotEmpty) {
                                        chatBloc.add(ChatGenerateNewTextMessageEvent(inputMessage: textEditingController.text));
                                        textEditingController.clear();
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
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}