// To parse this JSON data, do
//
//     final commentModel = commentModelFromJson(jsonString);

import 'dart:convert';

CommentModel commentModelFromJson(String str) => CommentModel.fromJson(json.decode(str));

String commentModelToJson(CommentModel data) => json.encode(data.toJson());

class CommentModel {
  User user;
  int commentId;
  String content;
  DateTime timeStr;
  int likedCount;

  CommentModel({
    required this.user,
    required this.commentId,
    required this.content,
    required this.timeStr,
    required this.likedCount,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    user: User.fromJson(json["user"]),
    commentId: json["commentId"],
    content: json["content"],
    timeStr: DateTime.parse(json["timeStr"]),
    likedCount: json["likedCount"],
  );

  Map<String, dynamic> toJson() => {
    "user": user.toJson(),
    "commentId": commentId,
    "content": content,
    "timeStr": "${timeStr.year.toString().padLeft(4, '0')}-${timeStr.month.toString().padLeft(2, '0')}-${timeStr.day.toString().padLeft(2, '0')}",
    "likedCount": likedCount,
  };
}

class User {
  String avatarUrl;
  String nickname;

  User({
    required this.avatarUrl,
    required this.nickname,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    avatarUrl: json["avatarUrl"],
    nickname: json["nickname"],
  );

  Map<String, dynamic> toJson() => {
    "avatarUrl": avatarUrl,
    "nickname": nickname,
  };
}
