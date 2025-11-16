// ... (imports)

class UserModel {
  String? id;
  String? name;
  String? email;
  String? profileImage;
  String? phoneNumber;
  String? about;
  String? status;
  String? fcmToken; // <-- ADD THIS LINE

  UserModel({
    this.id,
    this.name,
    this.email,
    this.profileImage,
    this.phoneNumber,
    this.about,
    this.status,
    this.fcmToken, // <-- ADD THIS LINE
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    profileImage: json["profileImage"],
    phoneNumber: json["phoneNumber"],
    about: json["about"],
    status: json["status"],
    fcmToken: json["fcmToken"], // <-- ADD THIS LINE
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "profileImage": profileImage,
    "phoneNumber": phoneNumber,
    "about": about,
    "status": status,
    "fcmToken": fcmToken, // <-- ADD THIS LINE
  };
}