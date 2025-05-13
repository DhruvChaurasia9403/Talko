// chat_bloc.dart
import 'dart:async';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatSuccessState(messages: const [])) {
    on<ChatGenerateNewTextMessageEvent>(chatGenerateNewTextMessageEvent);
  }

  List<ChatMessageModel> messages = [];
  bool generating = false;

  FutureOr<void> chatGenerateNewTextMessageEvent(
      ChatGenerateNewTextMessageEvent event, Emitter<ChatState> emit) async {
    if (event.inputMessage.isNotEmpty) {
      print('Received inputMessage: ${event.inputMessage}');
      messages.add(ChatMessageModel(
          role: "user", parts: [ChatPartModel(text: event.inputMessage)]));
      emit(ChatSuccessState(messages: messages));
      generating = true;
      String generatedText = await ChatRepo.chatTextGenerationRepo(messages);
      if (generatedText.isNotEmpty) {
        messages.add(ChatMessageModel(
            role: 'model', parts: [ChatPartModel(text: generatedText)]));
        emit(ChatSuccessState(messages: messages));
      }
      generating = false;
    } else {
      print('Received null or empty inputMessage');
      return;
    }
  }
}