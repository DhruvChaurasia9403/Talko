// File: AI/bloc/chat_bloc.dart

import 'dart:async';
import 'dart:convert'; // <-- ADD THIS
import 'package:bloc/bloc.dart';
import 'package:chatting/AI/Model/chat_message_model.dart';
// import 'package:chatting/AI/repo/chat_repo.dart'; // <-- This is GONE
import 'package:http/http.dart' as http; // <-- ADD THIS
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatSuccessState(messages: const [])) {
    on<ChatGenerateNewTextMessageEvent>(chatGenerateNewTextMessageEvent);
  }

  List<ChatMessageModel> messages = [];
  bool generating = false;

  // This is the URL to your new server endpoint
  final String chatApiUrl = "https://chatting-server-17pa.onrender.com/generateChatText";

  FutureOr<void> chatGenerateNewTextMessageEvent(
      ChatGenerateNewTextMessageEvent event, Emitter<ChatState> emit) async {
    if (event.inputMessage.isNotEmpty) {
      print('Received inputMessage: ${event.inputMessage}');
      messages.add(ChatMessageModel(
          role: "user", parts: [ChatPartModel(text: event.inputMessage)]));
      emit(ChatSuccessState(messages: messages));
      generating = true;

      // --- THIS IS THE NEW SECURE LOGIC ---
      try {
        // Convert our message list to a format the server can read
        final messageMaps = messages.map((msg) => msg.toMap()).toList();

        final response = await http.post(
          Uri.parse(chatApiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'messages': messageMaps}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          String generatedText = data['generatedText'];

          messages.add(ChatMessageModel(
              role: 'model', parts: [ChatPartModel(text: generatedText)]));
          emit(ChatSuccessState(messages: messages));
        } else {
          // Handle server error
          print("Server Error: ${response.body}");
          messages.add(ChatMessageModel(
              role: 'model', parts: [ChatPartModel(text: "Error: ${response.body}")]));
          emit(ChatSuccessState(messages: messages));
        }
      } catch (e) {
        // Handle network or other errors
        print("Chat Error: $e");
        messages.add(ChatMessageModel(
            role: 'model', parts: [ChatPartModel(text: "An error occurred: $e")]));
        emit(ChatSuccessState(messages: messages));
      }
      // --- END OF NEW LOGIC ---

      generating = false;
    } else {
      print('Received null or empty inputMessage');
      return;
    }
  }
}