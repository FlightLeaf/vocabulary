// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String name;
  String email;
  String password;
  String time;
  String img;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.time,
    required this.img,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json["name"],
    email: json["email"],
    password: json["password"],
    time: json["time"],
    img: json["img"]
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "password": password,
    "time": time,
    "img":img
  };
}
