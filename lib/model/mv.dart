// To parse this JSON data, do
//
//     final newMvModel = newMvModelFromJson(jsonString);

import 'dart:convert';

MvModel newMvModelFromJson(String str) => MvModel.fromJson(json.decode(str));

String newMvModelToJson(MvModel data) => json.encode(data.toJson());

class MvModel {
  int id;
  String name;
  String artistName;
  String? desc; // 修改此处，允许desc为null
  String cover;
  DateTime publishTime;
  Map<String, String> brs;

  MvModel({
    required this.id,
    required this.name,
    required this.artistName,
    this.desc, // 修改此处，添加问号表示可以为空
    required this.cover,
    required this.publishTime,
    required this.brs,
  });

  factory MvModel.fromJson(Map<String, dynamic> json) => MvModel(
    id: json["id"],
    name: json["name"],
    artistName: json["artistName"],
    desc: json["desc"], // 修改此处，允许desc为null
    cover: json["cover"],
    publishTime: DateTime.parse(json["publishTime"]),
    brs: Map.from(json["brs"]).map((k, v) => MapEntry<String, String>(k, v)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "artistName": artistName,
    "desc": desc, // 修改此处，允许desc为null
    "cover": cover,
    "publishTime": "${publishTime.year.toString().padLeft(4, '0')}-${publishTime.month.toString().padLeft(2, '0')}-${publishTime.day.toString().padLeft(2, '0')}",
    "brs": Map.from(brs).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };
}

