import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

String fileSQL = "/data/user/0/com.vocabulary.vocabulary/files/ok.sqlite";

Future<bool> fileExists(String filePath) async {
  return File(filePath).exists();
}

Future<void> readAndWriteImage() async {
  String fileName = "ok.sqlite";
  String dir = (await getApplicationSupportDirectory()).path;
  fileSQL = "$dir/$fileName";

  if(await fileExists(fileSQL)){

  }else{
    var bytes = await rootBundle.load("assets/recMusic.sqlite");
    ByteBuffer buffer =  bytes.buffer;
    File file = await File(fileSQL).writeAsBytes(buffer.asUint8List(bytes.offsetInBytes,
        bytes.lengthInBytes));
  }
}

Future<void> inSearch(String word) async {
  Database? database;
    // 打开数据库连接
  database = await sqlite3.open(fileSQL);
  var insertStatement = await database.prepare('''
      INSERT OR REPLACE INTO searchWordTime (word)
      VALUES (?)
    ''');
  insertStatement.execute([
    word
  ]);
  database.dispose();
}

Future<void> deSearch() async {
  Database? database;
  database = await sqlite3.open(fileSQL);
  database.execute('DELETE FROM searchWordTime');
  database.dispose();
}
