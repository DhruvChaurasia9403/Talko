import 'package:chatting/Model/UserModel.dart';

class ChatRoomModel {
  String? id;
  UserModel? sender;
  UserModel? receiver;
  List<String>? participants;
  String? lastMessage;
  String? unReadMessageNo;
  DateTime? timeStamp;
  DateTime? lastMessageTimeStamp;
  String? lastMessageSenderId; // <-- THE CORE FIX

  bool? isGroup;
  String? groupName;
  String? groupIcon;
  List<String>? adminIds;

  ChatRoomModel({
    this.id,
    this.sender,
    this.receiver,
    this.participants,
    this.lastMessage,
    this.unReadMessageNo,
    this.timeStamp,
    this.lastMessageTimeStamp,
    this.lastMessageSenderId, // <-- NEW
    this.isGroup = false,
    this.groupName,
    this.groupIcon,
    this.adminIds,
  });

  ChatRoomModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sender = json['sender'] != null ? UserModel.fromJson(json['sender']) : null;
    receiver = json['receiver'] != null ? UserModel.fromJson(json['receiver']) : null;
    participants = json['participants'] != null ? List<String>.from(json['participants']) : null;
    lastMessage = json['lastMessage'];
    unReadMessageNo = json['unReadMessageNo'];
    timeStamp = json['timeStamp'] != null ? DateTime.parse(json['timeStamp']) : null;
    lastMessageTimeStamp = json['lastMessageTimeStamp'] != null ? DateTime.parse(json['lastMessageTimeStamp']) : null;
    lastMessageSenderId = json['lastMessageSenderId']; // <-- NEW
    isGroup = json['isGroup'] ?? false;
    groupName = json['groupName'];
    groupIcon = json['groupIcon'];
    adminIds = json['adminIds'] != null ? List<String>.from(json['adminIds']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (sender != null) {
      data['sender'] = sender!.toJson();
    }
    if (receiver != null) {
      data['receiver'] = receiver!.toJson();
    }
    data['participants'] = participants;
    data['lastMessage'] = lastMessage;
    data['unReadMessageNo'] = unReadMessageNo;
    if (timeStamp != null) {
      data['timeStamp'] = timeStamp!.toIso8601String();
    }
    if (lastMessageTimeStamp != null) {
      data['lastMessageTimeStamp'] = lastMessageTimeStamp!.toIso8601String();
    }
    data['lastMessageSenderId'] = lastMessageSenderId; // <-- NEW
    data['isGroup'] = isGroup;
    data['groupName'] = groupName;
    data['groupIcon'] = groupIcon;
    data['adminIds'] = adminIds;
    return data;
  }
}