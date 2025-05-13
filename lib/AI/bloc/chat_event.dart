part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class ChatGenerateNewTextMessageEvent extends ChatEvent {
  final String inputMessage;
  final String? imagePath;
  ChatGenerateNewTextMessageEvent({
    required this.inputMessage,
    this.imagePath,
  });
}