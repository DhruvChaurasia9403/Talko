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
  // String? createdAt;
  // DateTime lastSeen;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.profileImage,
    this.phoneNumber,
    this.about,
    // this.createdAt,
    // required this.lastSeen,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    profileImage: json["profileImage"],
    phoneNumber: json["phoneNumber"],
    about: json["about"],
    // createdAt: json["createdAt"],
    // lastSeen: json["lastSeen"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "profileImage": profileImage,
    "phoneNumber": phoneNumber,
    "about": about,
    // "createdAt": createdAt,
    // "lastSeen": lastSeen,
  };
}
