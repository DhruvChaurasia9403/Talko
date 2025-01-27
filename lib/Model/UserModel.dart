// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? id;
  String? name;
  String? email;
  String? profileImage;
  String? phoneNumber;
  String? about;
  String? status;
  // DateTime? lastSeen; // Add the lastSeen field
  // DateTime? accountCreated; // Add the accountCreated field

  UserModel({
    this.id,
    this.name,
    this.email,
    this.profileImage,
    this.phoneNumber,
    this.about,
    this.status,
    // this.lastSeen,
    // this.accountCreated,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    profileImage: json["profileImage"],
    phoneNumber: json["phoneNumber"],
    about: json["about"],
    status: json["status"],
    // lastSeen: json["lastSeen"] != null ? DateTime.parse(json["lastSeen"]) : null,
    // accountCreated: json["accountCreated"] != null ? DateTime.parse(json["accountCreated"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "profileImage": profileImage,
    "phoneNumber": phoneNumber,
    "about": about,
    "status": status,
    // "lastSeen": lastSeen?.toIso8601String(),
    // "accountCreated": accountCreated?.toIso8601String(),
  };
}