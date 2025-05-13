import 'dart:ui';
import 'package:artificial_intelegence/Model/chat_message_model.dart';
import 'package:artificial_intelegence/bloc/chat_bloc.dart';
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
  final ScrollController _scrollController = ScrollController(); // Scroll controller for auto-scrolling

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0;
    });
  }

  /// Function to scroll to the bottom of the chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ChatBloc, ChatState>(
        bloc: chatBloc,
        listener: (context, state) {
          if (state is ChatSuccessState) {
            _scrollToBottom(); // Scroll down when a new message arrives
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case ChatSuccessState:
              List<ChatMessageModel> message = (state as ChatSuccessState).messages;
              return Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/earth.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: _isKeyboardVisible ? 8.0 : 0.0, sigmaY: _isKeyboardVisible ? 8.0 : 0.0),
                    child: Container(
                      color: Colors.black.withOpacity(_isKeyboardVisible ? 0.3 : 0.2),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 60),
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "V.O.I.D.",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Sixtyfour'
                              ),
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController, // Attach scroll controller
                          itemCount: message.length,
                          itemBuilder: (context, index) {
                            bool isUserMessage = message[index].role == 'user';
                            return Align(
                              alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: isUserMessage ? Theme.of(context).primaryColor : Colors.black.withOpacity(0.5),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                child: Text(
                                  message[index].parts[0].text,
                                  style: isUserMessage ? const TextStyle(color: Colors.black) : const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (chatBloc.generating)
                        Row(
                          children: [
                            SizedBox(
                                height: 100,
                                width: 100,
                                child: Lottie.asset('assets/loader.json')),
                            const SizedBox(width: 20),
                            const Text("Loading...")
                          ],
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: textEditingController,
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                maxLines: 3,
                                minLines: 1,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  hintText: "Ask Artificial Intelligence",
                                  hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  fillColor: Colors.black12,
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.transparent,
                                child: IconButton(
                                  icon: const Icon(Icons.send, color: Colors.white),
                                  onPressed: () {
                                    chatBloc.add(ChatGenerateNewTextMessageEvent(inputMessage: textEditingController.text));
                                    textEditingController.clear();
                                    _scrollToBottom(); // Scroll down after sending message
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
