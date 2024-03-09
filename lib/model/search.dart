// To parse this JSON data, do
//
//     final searchModel = searchModelFromJson(jsonString);

import 'dart:convert';

SearchModel searchModelFromJson(Map<String, dynamic> str) => SearchModel.fromJson(str);

String searchModelToJson(SearchModel data) => json.encode(data.toJson());

class SearchModel {
  int id;
  String name;
  List<Artist> artists;
  int duration;

  SearchModel({
    required this.id,
    required this.name,
    required this.artists,
    required this.duration,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
    id: json["id"],
    name: json["name"],
    artists: List<Artist>.from(json["artists"].map((x) => Artist.fromJson(x))),
    duration: json["duration"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "artists": List<dynamic>.from(artists.map((x) => x.toJson())),
    "duration": duration,
  };
}

class Artist {
  int id;
  String name;

  Artist({
    required this.id,
    required this.name,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
