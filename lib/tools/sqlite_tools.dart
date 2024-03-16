import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:vocabulary/model/music.dart';

import 'sharedPreferences_tools.dart';

class SqlTools {
  static String fileSQL =
      "/data/user/0/com.vocabulary.vocabulary/files/ok.sqlite";

  static Future<bool> fileExists(String filePath) async {
    return File(filePath).exists();
  }

  static Future<void> readAndWriteImage() async {
    String fileName = "ok.sqlite";
    String dir = (await getApplicationSupportDirectory()).path;
    fileSQL = "$dir/$fileName";
    bool isFirstLaunch = !DataUtils.hasKey('launchedBefore');
    if (isFirstLaunch) {
      print('首次启动！！！！');
      DataUtils.putBool('launchedBefore', true);
      var bytes = await rootBundle.load("assets/recMusic.sqlite");
      ByteBuffer buffer = bytes.buffer;
      File file = await File(fileSQL).writeAsBytes(
          buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    }
  }

  static final Database _database = sqlite3.open(fileSQL);

  static void inSearch(String word) {
    var insertStatement = _database.prepare('''
      INSERT OR REPLACE INTO searchWordTime (word)
      VALUES (?)
    ''');
    insertStatement.execute([word]);
  }

  static void inTimeMusic(MusicModel model) {
    DateTime now = DateTime.now();
    String currentTime = now.millisecondsSinceEpoch.toString(); // 将当前时间转换为字符串
    var insertStatement = _database.prepare('''
      INSERT OR REPLACE INTO history (id, name, artist, pic, lrc, url, time)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    ''');
    insertStatement.execute([
      model.id,
      model.name,
      model.author,
      model.picUrl,
      '',
      model.mp3Url,
      currentTime
    ]);
  }

  static void inLoveMusic(MusicModel model) {
    DateTime now = DateTime.now();
    String currentTime = now.millisecondsSinceEpoch.toString(); // 将当前时间转换为字符串

    var insertStatement = _database.prepare('''
      INSERT OR REPLACE INTO love (id, name, artist, pic, lrc, url, time)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    ''');
    insertStatement.execute([
      model.id,
      model.name,
      model.author,
      model.picUrl,
      '',
      model.mp3Url,
      currentTime
    ]);
    showToast('已填加至收藏');
  }

  static void inDownload(MusicModel model) {
    DateTime now = DateTime.now();
    String currentTime = now.millisecondsSinceEpoch.toString(); // 将当前时间转换为字符串

    if (isLocal(model.id.toString())) {
      showToast('已下载');
    } else {
      var insertStatement = _database.prepare('''
      INSERT OR REPLACE INTO download (id, name, artist, pic, lrc, url, time)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    ''');
      insertStatement.execute([
        model.id,
        model.name,
        model.author,
        model.picUrl,
        '',
        model.mp3Url,
        currentTime
      ]);
      showToast('下载完成');
    }
  }

  static Future<void> deSearch() async {
    _database.execute('DELETE FROM searchWordTime');
    showToast('删除成功');
  }

  static void deTime(String id) {
    // 准备删除语句
    var deleteStatement = _database.prepare('''
    DELETE FROM history WHERE id = ?
  ''');
    // 执行删除操作，传入ID参数
    deleteStatement.execute([id]);
    showToast('删除成功');
  }

  static void deLocal(String id) {
    // 准备删除语句
    var deleteStatement = _database.prepare('''
    DELETE FROM download WHERE id = ?
  ''');
    // 执行删除操作，传入ID参数
    deleteStatement.execute([id]);
    showToast('删除成功');
  }

  static void deLove(String id) {
    // 准备删除语句
    var deleteStatement = _database.prepare('''
    DELETE FROM love WHERE id = ?
  ''');
    // 执行删除操作，传入ID参数
    deleteStatement.execute([id]);
    showToast('删除成功');
  }

  static bool isLoveMusic(String id) {
    // 准备查询语句
    var queryStatement = _database.prepare('''
    SELECT * FROM love WHERE id = ?
  ''');
    // 执行查询操作，传入ID参数
    var result = queryStatement.select([id]);
    return result.isNotEmpty;
  }

  static bool isLocal(String id) {
    // 准备查询语句
    var queryStatement = _database.prepare('''
    SELECT * FROM download WHERE id = ?
  ''');
    // 执行查询操作，传入ID参数
    var result = queryStatement.select([id]);
    return result.isNotEmpty;
  }
}
