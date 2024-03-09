// To parse this JSON data, do
//
//     final hotModel = hotModelFromJson(jsonString);

import 'dart:convert';

HotModel hotModelFromJson(String str) => HotModel.fromJson(json.decode(str));

String hotModelToJson(HotModel data) => json.encode(data.toJson());

class HotModel {
  String searchWord;
  String? iconUrl; // 允许iconUrl为null

  HotModel({
    required this.searchWord,
    this.iconUrl, // 这里也要修改，允许iconUrl为空
  });

  factory HotModel.fromJson(Map<String, dynamic> json) => HotModel(
    searchWord: json["searchWord"],
    iconUrl: json["iconUrl"], // 从JSON中读取时，也可以是null
  );

  Map<String, dynamic> toJson() => {
    "searchWord": searchWord,
    "iconUrl": iconUrl, // 转换为JSON时，如果iconUrl为null，则JSON中也将包含null
  };
}
