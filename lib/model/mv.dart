// To parse this JSON data, do
//
//     final mvModel = mvModelFromJson(jsonString);

import 'dart:convert';

MvModel mvModelFromJson(String str) => MvModel.fromJson(json.decode(str));

String mvModelToJson(MvModel data) => json.encode(data.toJson());

class MvModel {
  String id;
  String songs;
  String sings;
  String cover;
  String mv;

  MvModel({
    required this.id,
    required this.songs,
    required this.sings,
    required this.cover,
    required this.mv,
  });

  factory MvModel.fromJson(Map<String, dynamic> json) => MvModel(
    id: json["id"],
    songs: json["songs"],
    sings: json["sings"],
    cover: json["cover"],
    mv: json["mv"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "songs": songs,
    "sings": sings,
    "cover": cover,
    "mv": mv,
  };
}
