// To parse this JSON data, do
//
//     final newMvModel = newMvModelFromJson(jsonString);

import 'dart:convert';

NewMvModel newMvModelFromJson(String str) => NewMvModel.fromJson(json.decode(str));

String newMvModelToJson(NewMvModel data) => json.encode(data.toJson());

class NewMvModel {
  int id;
  String name;
  String artistName;
  String desc;
  String cover;
  DateTime publishTime;
  Map<String, String> brs;

  NewMvModel({
    required this.id,
    required this.name,
    required this.artistName,
    required this.desc,
    required this.cover,
    required this.publishTime,
    required this.brs,
  });

  factory NewMvModel.fromJson(Map<String, dynamic> json) => NewMvModel(
    id: json["id"],
    name: json["name"],
    artistName: json["artistName"],
    desc: json["desc"],
    cover: json["cover"],
    publishTime: DateTime.parse(json["publishTime"]),
    brs: Map.from(json["brs"]).map((k, v) => MapEntry<String, String>(k, v)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "artistName": artistName,
    "desc": desc,
    "cover": cover,
    "publishTime": "${publishTime.year.toString().padLeft(4, '0')}-${publishTime.month.toString().padLeft(2, '0')}-${publishTime.day.toString().padLeft(2, '0')}",
    "brs": Map.from(brs).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };
}
