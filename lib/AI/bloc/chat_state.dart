part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

class ChatInitialState extends ChatState {}

class ChatSuccessState extends ChatState {
  final List<ChatMessageModel> messages;

  ChatSuccessState({required this.messages});
}

class ChatErrorState extends ChatState {
  final String error;

  ChatErrorState({required this.error});
}

class ChatLoadingState extends ChatState {}