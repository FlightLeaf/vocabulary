import 'dart:convert';

MusicModel musicFromJson(String str) => MusicModel.fromMap(json.decode(str));

String musicToJson(MusicModel data) => json.encode(data.toJson());

class MusicModel {
  int id;
  String name;
  String author;
  String? picUrl;
  String mp3Url;

  MusicModel({
    required this.id,
    required this.name,
    required this.author,
    required this.mp3Url,
    this.picUrl,
  });

  factory MusicModel.fromMap(Map<String, dynamic> json) => MusicModel(
    id: json["song_id"],
    name: json["name"]!,
    author: json["author"]!,
    picUrl: json["cover"]!,
    mp3Url: json["mp3url"]!,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "author": author,
    "picUrl": picUrl!,
    "mp3Url": mp3Url,
  };
}
