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

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // 1. Bulletproof Timestamp Parsing
    DateTime? parsedTimestamp;
    if (json["timestamp"] != null) {
      if (json["timestamp"] is Timestamp) {
        parsedTimestamp = (json["timestamp"] as Timestamp).toDate();
      } else if (json["timestamp"] is String) {
        parsedTimestamp = DateTime.tryParse(json["timestamp"]);
      } else if (json["timestamp"] is int) {
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(json["timestamp"]);
      }
    }

    return ChatModel(
      id: json["id"]?.toString(),
      message: json["message"]?.toString(),
      senderName: json["senderName"]?.toString(),
      senderId: json["senderId"]?.toString(),
      receiverId: json["receiverId"]?.toString(),
      timestamp: parsedTimestamp,
      readStatus: json["readStatus"]?.toString() ?? 'unknown',
      imageUrl: json["imageUrl"]?.toString(),
      videoUrl: json["videoUrl"]?.toString(),
      audioUrl: json["audioUrl"]?.toString(),
      documentUrl: json["documentUrl"]?.toString(),
      // 2. Safe List Parsing
      reactions: json["reactions"] is List ? List<String>.from(json["reactions"]) : null,
      replies: json["replies"] is List ? List<dynamic>.from(json["replies"]) : null,
    );
  }

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
    "reactions": reactions != null ? List<dynamic>.from(reactions!) : null,
    "replies": replies != null ? List<dynamic>.from(replies!) : null,
  };
}