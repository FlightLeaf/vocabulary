import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:sqlite3/sqlite3.dart';
import 'package:vocabulary/model/comment.dart';
import 'package:vocabulary/model/music.dart';
import 'package:vocabulary/model/mv.dart';

import '../model/hot.dart';
import 'sqlite_tools.dart';

/// ApiDio类用于处理网络请求和数据存储
class ApiDio {
  /// 存储被禁歌曲的列表
  static List<String> ban = [];
  /// 热门模型列表
  static List<HotModel> hotModelList = [];
  /// 音乐歌单列表
  static List<MusicModel> musicSheetList = [];

  /// 搜索历史列表
  static List<String> searchList = [];
  /// 歌词映射表
  static Map<String, String> lyricsMap = {};

  static List<MvModel> newMvList = [];

  static List<String> idList = [];

  static List<MusicModel> randomList = [];

  static List<CommentModel> commentList = [];

  static List<MusicModel> historyList = [];
  static List<MusicModel> loveList = [];
  static List<MusicModel> localList = [];

  /// 获取热搜
  /// 返回值：获取成功返回true，失败返回false
  static Future<bool> getHotList() async {
    Map<String, dynamic> jsonMap = {};
    try {
      Response response = await Dio().get("http://114.55.94.213:3000/search/hot/detail");
      jsonMap = json.decode(response.toString());
      List<dynamic> dataList = jsonMap['data'];
      hotModelList = dataList.map((item) {
        return HotModel.fromJson(item);
      }).toList();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 根据关键词进行搜索
  /// [word]：搜索的关键词
  /// 返回值：搜索结果的字符串
  static Future<String> getSearch(String word) async {
    String res = '';
    try {
      Response response = await Dio().get("https://music.163.com/api/search/get/web?csrf_token=hlpretag=&hlposttag=&s=$word&type=1&offset=0&total=true&limit=25");
      res = response.toString();
      return res;
    } catch (e) {
      return res;
    }
  }

  /// 根据歌曲ID获取MP3模型
  /// [id]：歌曲的ID
  /// 返回值：音乐模型对象
  static Future<MusicModel> getMp3Model(String id) async {
    try {
      Response response = await Dio().get("https://api.vvhan.com/api/music?id=$id&type=song&media=netease");
      Map<String, dynamic> data = json.decode(response.toString());
      return MusicModel(id: data['song_id'], name: data['name'], author: data['author'], picUrl: data['cover'], mp3Url: 'https://api.injahow.cn/meting/?server=netease&type=url&id=${data['song_id']}',);
    } catch (e) {
      return MusicModel(id: 1, name: '', author: '', picUrl: '', mp3Url: '');
    }
  }

  /// 根据歌曲ID获取音乐信息
  /// [id]：歌曲的ID
  /// 返回值：音乐模型对象
  static Future<MusicModel> getMusic(String id) async {
    MusicModel musicId;
    try {
      Response response = await Dio().get("https://api.vvhan.com/api/music?id=$id&type=song&media=netease");
      Map<String, dynamic> mp3 = json.decode(response.toString());
      musicId = MusicModel.fromMap(mp3);
      return musicId;
    } catch (e) {
      musicId = MusicModel(id:0 , name: '', author: '', picUrl: '', mp3Url: '');
      return musicId;
    }
  }

  /// 获取歌单推荐音乐列表
  static Future<void> getSheet() async {
    late Database database;
    database = sqlite3.open(SqlTools.fileSQL);
    // 从数据库中随机获取推荐音乐列表
    var query = 'SELECT * FROM RecdMusicList ORDER BY RANDOM() LIMIT 10';
    var results = database.select(query);

    musicSheetList.clear();

    results.forEach((element) {
      musicSheetList.add(MusicModel(id: int.parse(element['id']), name: element['name'], author: element['artist'], picUrl: element['pic'], mp3Url: element['url']),);
    });
    database.dispose();
  }

  /// 获取歌单推荐音乐列表
  static void getHistory() {
    late Database database;
    database = sqlite3.open(SqlTools.fileSQL);

    var query = '''
      SELECT d1.*
      FROM history d1
      INNER JOIN (
        SELECT id, MAX(time) as maxTime
        FROM history
        GROUP BY id
      ) d2 ON d1.id = d2.id AND d1.time = d2.maxTime
      ORDER BY d1.time DESC
    ''';

    var results = database.select(query);
    historyList.clear();
    results.forEach((element) {
      historyList.add(MusicModel(id: int.parse(element['id']), name: element['name'], author: element['artist'], picUrl: element['pic'], mp3Url: element['url']),);
    });
    database.dispose();
  }

  /// 获取歌单推荐音乐列表
  static Future<void> getLove() async {
    late Database database;
    database = sqlite3.open(SqlTools.fileSQL);

    var query = 'SELECT DISTINCT * FROM love';
    var results = database.select(query);

    loveList.clear();
    results.forEach((element) {
      loveList.add(MusicModel(id: int.parse(element['id']), name: element['name'], author: element['artist'], picUrl: element['pic'], mp3Url: element['url']),);
    });
    database.dispose();
  }

  /// 获取歌单推荐音乐列表
  static Future<void> getDownload() async {
    late Database database;
    database = sqlite3.open(SqlTools.fileSQL);

    var query = 'SELECT * FROM download';
    var results = database.select(query);

    localList.clear();
    results.forEach((element) {
      localList.add(MusicModel(id: int.parse(element['id']), name: element['name'], author: element['artist'], picUrl: element['pic'], mp3Url: element['url']),);
    });
    database.dispose();
  }

  /// 根据MV ID获取MV的URL
  /// [id]：MV的ID
  /// 返回值：MV的URL字符串
  static Future<String> getMvURL(String id) async {
    try {
      Response response = await Dio().post("http://music.163.com/api/mv/detail?id=$id&type=mp4");
      Map<String, dynamic> mp4 = json.decode(response.toString());
      String data = mp4['data']['brs']['720'];
      return data;
    } catch (e) {
      return '';
    }
  }

  /// 获取搜索历史关键词列表
  static Future<void> getSearchWord() async {
    late Database database;
    database = sqlite3.open(SqlTools.fileSQL);
    // 从数据库中获取搜索历史关键词
    var query = 'SELECT DISTINCT word FROM searchWordTime';
    var results = database.select(query);
    searchList.clear();

    results.forEach((element) {
      searchList.add(element['word']);
    });
    database.dispose();
  }

  /// 获取被禁展示图片列表
  static Future<bool> getBan() async{
    try {
      Response response = await Dio().get("http://114.55.94.213:3000/banner?type=1");
      Map<String, dynamic> mp3 = json.decode(response.toString());
      List<dynamic> banList = mp3['banners'];

      for (Map<String, dynamic> bans in banList){
        ban.add(bans['pic']);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 根据歌单ID获取歌单详情
  /// [id]：歌单的ID
  /// 返回值：音乐模型列表
  static Future<List<MusicModel>> getSheetDetail(String id) async{
    List<MusicModel> musicModelList = [];
    try {
      Response response = await Dio().get('https://api.injahow.cn/meting/?type=playlist&id=$id');
      return musicModelList;
    } catch (e) {
      return musicModelList;
    }
  }

  /// 获取指定歌曲的歌词
  /// [id]：歌曲的ID
  static Future<void> getWord(String id) async{
    try {
      Response response = await Dio().get('https://music.163.com/api/song/lyric?id=$id&lv=1&kv=1&tv=-1');
      Map<String, dynamic> map = json.decode(response.toString());
      String lrc = map['lrc']['lyric'];
      lyricsMap.clear();
      lyricsMap = getLyric(lrc);
    } catch (e) {
    }
  }

  // 从歌词字符串中解析出时间戳和歌词内容，并存储到lyricsMap中
  static Map<String, String> getLyric(String lyrics)  {
    Map<String, String> lyricsMap = {};
    final regex = RegExp(r'\[(\d+:\d+\.\d+)\](.*)');
    for (final match in regex.allMatches(lyrics)) {
      // 提取时间戳和歌词
      final timestamp = match.group(1)!;
      final line = match.group(2);
      // 只保留分钟和秒
      final minSec = timestamp.split('.')[0];
      // 添加到Map中
      lyricsMap[minSec] = line!;
    }
    return lyricsMap;
  }

  /// 获取随机推荐音乐
  /// 返回值：音乐模型对象
  static Future<void> getRandomMusic(int i) async{
    try {
      while(i>0){
        Response response = await Dio().get('https://api.vvhan.com/api/rand.music?type=json&sort=%E7%83%AD%E6%AD%8C%E6%A6%9C');
        Map<String, dynamic> map = json.decode(response.toString());
        Map<String, dynamic> rand = map['info'];
        if(rand['mp3url'] == 'https://music.163.com/404'){
          continue;
        }else{
          randomList.add(MusicModel(id: rand['id'], name: rand['name'].toString(), author: rand['auther'].toString(), picUrl: rand['picUrl'], mp3Url: rand['mp3url']));
          i = i-1;
        }
      }
      if(randomList.length > 3){
        randomList.removeAt(0);
      }
      print('list length===================: ${randomList.length}');
    } catch (e) {
      print(e);
    }
  }

  static Future<void> getNewMVID() async{
    newMvList.clear();
    try {
      idList.clear();
      Response response = await Dio().get('http://114.55.94.213:3000/top/mv?limit=10');
      Map<String, dynamic> map = json.decode(response.toString());
      List<dynamic> rand = map['data'];
      rand.forEach((element) {
        String id = element['id'].toString();
        idList.add(id);
      });
    } catch (e) {
    }
  }


  static Future<void> getNewMV() async {

    try {
      newMvList.clear();
      for(String id in idList){
        Response response = await Dio().post("http://music.163.com/api/mv/detail?id=$id&type=mp4");
        Map<String, dynamic> mp4 = json.decode(response.toString());
        Map<String, dynamic> rand = mp4['data'];
        newMvList.add(MvModel.fromJson(rand));
      }
    } catch (e) {
    }
  }

  static Future<void> getComment(String id) async {
    try {
      commentList.clear();
      Response response = await Dio().get('http://music.163.com/api/v1/resource/comments/R_SO_4_$id?limit=20&offset=0');
      Map<String, dynamic> map = json.decode(response.toString());
      List<dynamic> rand = map['hotComments'];
      rand.forEach((element) {
        commentList.add(CommentModel.fromJson(element));
      });
      print('============='+commentList.length.toString());
    } catch (e) {
    }
  }
}
