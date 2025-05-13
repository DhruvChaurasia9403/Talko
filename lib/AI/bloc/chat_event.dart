part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class ChatGenerateNewTextMessageEvent extends ChatEvent {
  final String inputMessage;

  ChatGenerateNewTextMessageEvent({
    required this.inputMessage,
  });
}

class ChatClearMessagesEvent extends ChatEvent {}