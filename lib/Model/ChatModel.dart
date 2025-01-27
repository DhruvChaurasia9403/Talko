import 'package:cloud_firestore/cloud_firestore.dart';
class ChatModel {
  String? id;
  String? message;
  String? senderName;
  String? senderId;
  String? receiverId;
  DateTime? timestamp;
  String? readStatus;
  String? imageUrl;
  String? videoUrl;
  String? audioUrl;
  String? documentUrl;
  List<String>? reactions;
  List<dynamic>? replies;
  ChatModel({
    this.id,
    this.message,
    this.senderName,
    this.senderId,
    this.receiverId,
    this.timestamp,
    this.readStatus,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
    this.documentUrl,
    this.reactions,
    this.replies,
  });
  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
    id: json["id"],
    message: json["message"],
    senderName: json["senderName"],
    senderId: json["senderId"],
    receiverId: json["receiverId"],
    timestamp: json["timestamp"] != null ? (json["timestamp"] as Timestamp).toDate() : null,
    readStatus: json["readStatus"],
    imageUrl: json["imageUrl"],
    videoUrl: json["videoUrl"],
    audioUrl: json["audioUrl"],
    documentUrl: json["documentUrl"],
    reactions: json["reactions"] != null ? List<String>.from(json["reactions"].map((x) => x)) : null,
    replies: json["replies"] != null ? List<dynamic>.from(json["replies"].map((x) => x)) : null,
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "message": message,
    "senderName": senderName,
    "senderId": senderId,
    "receiverId": receiverId,
    "timestamp": timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    "readStatus": readStatus,
    "imageUrl": imageUrl,
    "videoUrl": videoUrl,
    "audioUrl": audioUrl,
    "documentUrl": documentUrl,
    "reactions": reactions != null ? List<dynamic>.from(reactions!.map((x) => x)) : null,
    "replies": replies != null ? List<dynamic>.from(replies!.map((x) => x)) : null,
  };
}