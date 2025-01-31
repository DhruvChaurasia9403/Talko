import 'dart:convert';

import 'package:chatting/Model/ChatModel.dart';
import 'package:chatting/Model/UserModel.dart';

ChatRoomModel chatRoomModelFromJson(String str) => ChatRoomModel.fromJson(json.decode(str));

String chatRoomModelToJson(ChatRoomModel data) => json.encode(data.toJson());

class ChatRoomModel {
  String? id;
  UserModel? sender;
  UserModel? receiver;
  List<ChatModel>? messages;
  String? unReadMessageNo;
  String? lastMessage;
  DateTime? lastMessageTimeStamp;
  DateTime? timeStamp;

  ChatRoomModel({
    this.id,
    this.sender,
    this.receiver,
    this.messages,
    this.unReadMessageNo,
    this.lastMessage,
    this.lastMessageTimeStamp,
    this.timeStamp,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) => ChatRoomModel(
    id: json["id"],
    sender: json["sender"] != null ? UserModel.fromJson(json["sender"]) : null,
    receiver: json["receiver"] != null ? UserModel.fromJson(json["receiver"]) : null,
    messages: json["messages"] != null
        ? List<ChatModel>.from(json["messages"].map((x) => ChatModel.fromJson(x)))
        : [],
    unReadMessageNo: json["unReadMessageNo"],
    lastMessage: json["lastMessage"],
    lastMessageTimeStamp: json["lastMessageTimeStamp"] != null
        ? DateTime.parse(json["lastMessageTimeStamp"])
        : null,
    timeStamp: json["timeStamp"] != null
        ? DateTime.parse(json["timeStamp"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sender": sender?.toJson(),
    "receiver": receiver?.toJson(),
    "messages": messages?.map((x) => x.toJson()).toList() ?? [],
    "unReadMessageNo": unReadMessageNo,
    "lastMessage": lastMessage,
    "lastMessageTimeStamp": lastMessageTimeStamp?.toIso8601String(),
    "timeStamp": timeStamp?.toIso8601String(),
  };
}
