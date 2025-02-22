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
  /// 轮播图列表
  static List<String> ban = [];
  /// 热搜列表
  static List<HotModel> hotModelList = [];
  /// 音乐列表
  static List<MusicModel> musicSheetList = [];
  /// 搜索历史列表
  static List<String> searchList = [];
  /// 歌词映射表
  static Map<String, String> lyricsMap = {};
  /// MV列表
  static List<MvModel> newMvList = [];
  /// MVID列表
  static List<String> idList = [];
  /// Search MV ID
  static List<String> searchMVIDList = [];
  /// 随机音乐列表
  static List<MusicModel> randomList = [];
  /// 评论列表
  static List<CommentModel> commentList = [];
  /// 评论列表
  static List<CommentModel> mvCommentList = [];
  ///历史音乐列表
  static List<MusicModel> historyList = [];
  /// 我喜欢的列表
  static List<MusicModel> loveList = [];
  ///本地音乐列表
  static List<MusicModel> localList = [];
  /// 初始列表
  static List<MusicModel> startList = [];

  static List<MvModel> searchMvList = [];

  static List<MvModel> mvHistory = [];

  static List<String> historySuggest = [];

  static final Dio _dio = Dio();

  static final Database _database = sqlite3.open(SqlTools.fileSQL);

  // 获取搜索建议
  static Future<void> getSearchSuggest(String keyword) async {
    historySuggest.clear();
    try {
      Response response = await _dio.get('http://159.75.108.178:3000/search/suggest?keywords=$keyword&type=mobile');
      Map<String, dynamic> jsonMap = json.decode(response.toString());
      List<dynamic> list = jsonMap['result']['allMatch'];
      for (var item in list) {
        historySuggest.add(item['keyword'].toString());
      }
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
    }
  }


  /// 获取热搜
  /// 返回值：获取成功返回true，失败返回false
  static Future<bool> getHotList() async {
    Map<String, dynamic> jsonMap = {};
    try {
      Response response = await _dio.get("http://159.75.108.178:3000/search/hot/detail");
      jsonMap = json.decode(response.toString());
      List<dynamic> dataList = jsonMap['data'];
      hotModelList = dataList.map((item) {
        return HotModel.fromJson(item);
      }).toList();
      return true;
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
      return false;
    }
  }

  /// 根据关键词进行搜索
  /// [word]：搜索的关键词
  /// 返回值：搜索结果的字符串
  static Future<String> getSearch(String word) async {
    String res = '';
    try {
      Response response = await _dio.get("https://music.163.com/api/search/get/web?csrf_token=hlpretag=&hlposttag=&s=$word&type=1&offset=0&total=true&limit=25");
      res = response.toString();
      return res;
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
      return res;
    }
  }

  /// 根据歌曲ID获取MP3模型
  /// [id]：歌曲的ID
  /// 返回值：音乐模型对象
  // static Future<MusicModel> getNewMusic(int ids) async {
  //   String id = ids.toString();
  //   try {
  //     Response response = await Dio().get("https://api.injahow.cn/meting/?type=song&id=$id");
  //     List<dynamic> dataList = json.decode(response.toString());
  //     Map<String, dynamic> data = dataList[0];
  //
  //     RegExp regex = RegExp(r"id=(\d+)");
  //     Match match = regex.firstMatch(data['pic'].toString())!;
  //     String pic = match.group(1)!;
  //     print(data['pic'].toString()+'==========================');
  //     print(pic);
  //     String newPic = 'https://p3.music.126.net/HT4j0f5ETtAiOiCHcLYBww==/$pic.jpg';
  //     return MusicModel(id: ids, name: data['name'], author: data['artist'], picUrl: newPic, mp3Url: 'https://api.injahow.cn/meting/?server=netease&type=url&id=$id',);
  //   } catch (e) {
  //     DeBugMessage.addMistake(e.toString());
  //     return MusicModel(id: 1, name: '', author: '', picUrl: '', mp3Url: '');
  //   }
  // }

  /// 根据歌曲ID获取音乐信息
  /// [id]：歌曲的ID
  /// 返回值：音乐模型对象
  static Future<MusicModel> getMusic(int id) async {
    MusicModel music;
    print('=================================='+id.toString());
    try {
      Response response = await Dio().get("https://api.linhun.vip/api/wyyyy?id=${id.toString()}&apiKey=7fd47321de52414340f3535e40b6893d");
      Map<String, dynamic> mp3 = json.decode(response.toString());
      music = MusicModel(id: id, name: mp3['name'], author: mp3['author'], picUrl: mp3['img'], mp3Url: 'https://api.injahow.cn/meting/?server=netease&type=url&id=$id');
      return music;
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
      music = MusicModel(id:0 , name: '', author: '', picUrl: '', mp3Url: '');
      return music;
    }
  }

  /// 根据歌曲ID获取音乐信息
  /// [id]：歌曲的ID
  /// 返回值：音乐模型对象
  // static Future<String> getNewMusicUrl(int id) async {
  //   String music;
  //   try {
  //     Response response = await Dio().get("https://api.linhun.vip/api/wyyyy?id=${id.toString()}&apiKey=7fd47321de52414340f3535e40b6893d");
  //     Map<String, dynamic> mp3 = json.decode(response.toString());
  //     music = mp3['mp3'];
  //     return music;
  //   } catch (e) {
  //     DeBugMessage.addMistake(e.toString());
  //     music = '';
  //     return music;
  //   }
  // }


  /// 获取歌单推荐音乐列表
  static Future<void> getSheet() async {
    // 从数据库中随机获取推荐音乐列表
    var query = 'SELECT * FROM RecdMusicList ORDER BY RANDOM() LIMIT 10';
    var results = _database.select(query);

    musicSheetList.clear();

    for (var element in results) {
      musicSheetList.add(MusicModel(id: int.parse(element['id']), name: element['name'], author: element['artist'], picUrl: element['pic'], mp3Url: element['url']),);
    }
  }

  static Future<void> getMvHistory() async {
    var query = '''
      SELECT d1.*
      FROM mvHistory d1
      INNER JOIN (
        SELECT id, MAX(time) as maxTime
        FROM mvHistory
        GROUP BY id
      ) d2 ON d1.id = d2.id AND d1.time = d2.maxTime
      ORDER BY d1.time DESC
    ''';
    var results = _database.select(query);
    mvHistory.clear();
    for (var element in results) {
      Map<String, dynamic> map = jsonDecode(element['data'].toString());
      mvHistory.add(MvModel.fromJson(map));
    }
  }

  /// 获取歌单推荐音乐列表
  static Future<void> getHistory() async {
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

    var results = _database.select(query);
    historyList.clear();
    for (var element in results) {
      historyList.add(MusicModel(id: int.parse(element['id']), name: element['name'], author: element['artist'], picUrl: element['pic'], mp3Url: element['url']),);
      //print(MusicModel(id: int.parse(element['id']), name: element['name'], author: element['artist'], picUrl: element['pic'], mp3Url: element['url']).toJson().toString());
    }
  }

  /// 获取我喜欢的音乐列表
  static Future<void> getLove() async {

    var query = 'SELECT DISTINCT * FROM love';
    var results = _database.select(query);

    loveList.clear();
    for (var element in results) {
      loveList.add(MusicModel(id: int.parse(element['id']), name: element['name'], author: element['artist'], picUrl: element['pic'], mp3Url: element['url']),);
    }
  }

  /// 获取本地音乐
  static Future<void> getDownload() async {

    var query = 'SELECT * FROM download';
    var results = _database.select(query);

    localList.clear();
    for (var element in results) {
      localList.add(MusicModel(id: int.parse(element['id']), name: element['name'], author: element['artist'], picUrl: element['pic'], mp3Url: element['url']),);
    }
  }

  /// 根据MV ID获取MV的URL
  /// [id]：MV的ID
  /// 返回值：MV的URL字符串
  static Future<String> getMvURL(String id) async {
    try {
      Response response = await _dio.post("http://music.163.com/api/mv/detail?id=$id&type=mp4");
      Map<String, dynamic> mp4 = json.decode(response.toString());
      Map<String, dynamic> dataUrl = mp4['data']['brs'];
      List<String> resolutions = ['1080', '720', '480', '240'];
      String url = '';
      for (String resolution in resolutions) {
        if (dataUrl.containsKey(resolution)) {
          if (resolution == '1080') {
            url = dataUrl['1080'].toString();
          } else if (resolution == '720') {
            url = dataUrl['720'].toString();
          } else if (resolution == '480') {
            url = dataUrl['480'].toString();
          } else if (resolution == '240') {
            url = dataUrl['240'].toString();
          }
          break;
        }else{
          continue;
        }
      }
      return url;
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
      return '';
    }
  }

  /// 获取搜索历史关键词列表
  static Future<void> getSearchWord() async {
    // 从数据库中获取搜索历史关键词
    var query = 'SELECT DISTINCT word FROM searchWordTime';
    var results = _database.select(query);
    searchList.clear();

    for (var element in results) {
      searchList.add(element['word']);
    }
  }

  /// 获取轮播图片列表
  static Future<bool> getBan() async{
    try {
      Response response = await _dio.get("http://159.75.108.178:3000/banner?type=1");
      Map<String, dynamic> mp3 = json.decode(response.toString());
      List<dynamic> banList = mp3['banners'];

      for (Map<String, dynamic> bans in banList){
        ban.add(bans['pic']);
      }
      return true;
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
      return false;
    }
  }

  /// 获取指定歌曲的歌词
  /// [id]：歌曲的ID
  static Future<void> getWord(String id) async{
    try {
      Response response = await _dio.get('https://music.163.com/api/song/lyric?id=$id&lv=1&kv=1&tv=-1');
      Map<String, dynamic> map = json.decode(response.toString());
      String lrc = map['lrc']['lyric'];
      lyricsMap.clear();
      lyricsMap = getLyric(lrc);
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
      return;
    }
  }

  /// 从歌词字符串中解析出时间戳和歌词内容，并存储到lyricsMap中
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
        Response response = await _dio.get('https://api.vvhan.com/api/wyMusic/%E7%83%AD%E6%AD%8C%E6%A6%9C?type=json');
        Map<String, dynamic> map = json.decode(response.toString());
        Map<String, dynamic> rand = map['info'];
        if(rand['url'] == 'https://music.163.com/404'){
          continue;
        }else{
          randomList.add(MusicModel(id: rand['id'], name: rand['name'].toString(), author: rand['auther'].toString(), picUrl: rand['picUrl'], mp3Url: 'https://api.injahow.cn/meting/?server=netease&type=url&id=${rand['id']}'));
          i = i-1;
        }
      }
      if(randomList.length > 3){
        randomList.removeAt(0);
      }
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
    }
  }

  /// 获取MvId
  static Future<void> getNewMvId() async{
    newMvList.clear();
    try {
      idList.clear();
      Response response = await _dio.get('http://159.75.108.178:3000/top/mv?limit=10');
      Map<String, dynamic> map = json.decode(response.toString());
      List<dynamic> rand = map['data'];
      for (var element in rand) {
        String id = element['id'].toString();
        idList.add(id);
      }
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
    }
  }

  /// 获取MvId
  static Future<void> getSearchMvId(String word) async{
    searchMVIDList.clear();
    try {
      searchMVIDList.clear();
      Response response = await _dio.get('https://api.linhun.vip/api/wyymv?name=$word&apiKey=7a5bf162a5ba66958d31c89d4320f39c');
      Map<String, dynamic> map = json.decode(response.toString());
      List<dynamic> rand = map['data'];
      for (var element in rand) {
        String id = element['id'].toString();
        searchMVIDList.add(id);
      }
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
    }
  }


  /// 获取MV
  static Future<void> getNewMV() async {
    try {
      newMvList.clear();
      for(String id in idList){
        Response response = await _dio.post("http://music.163.com/api/mv/detail?id=$id&type=mp4");
        Map<String, dynamic> mp4 = json.decode(response.toString());
        Map<String, dynamic> rand = mp4['data'];
        newMvList.add(MvModel.fromJson(rand));
      }
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
    }
  }

  /// 获取MV
  static Future<void> getSearchMV() async {
    try {
      searchMvList.clear();
      int num = 0;
      for(String id in searchMVIDList){
        num = num + 1;
        Response response = await _dio.post("http://music.163.com/api/mv/detail?id=$id&type=mp4");
        Map<String, dynamic> mp4 = json.decode(response.toString());
        Map<String, dynamic> rand = mp4['data'];
        searchMvList.add(MvModel.fromJson(rand));
        print(searchMvList);
        if(num == 9) return;
      }
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
    }
  }

  /// 获取音乐评论
  static Future<void> getComment(String id) async {
    try {
      commentList.clear();
      Response response = await _dio.get('http://music.163.com/api/v1/resource/comments/R_SO_4_$id?limit=20&offset=0');
      Map<String, dynamic> map = json.decode(response.toString());
      List<dynamic> rand = map['hotComments'];
      for (var element in rand) {
        commentList.add(CommentModel.fromJson(element));
      }
    } catch (e) {
      //DeBugMessage.addMistake(e.toString());
    }
  }

  /// 获取MV评论
  static Future<void> getMvComment(String id) async {
    try {
      mvCommentList.clear();
      Response response = await _dio.get('http://159.75.108.178:3000/comment/mv?id=$id');
      Map<String, dynamic> map = json.decode(response.toString());
      List<dynamic> rand = map['hotComments'];
      for (var element in rand) {
        mvCommentList.add(CommentModel.fromJson(element));
      }
    }catch (e) {
      //DeBugMessage.addMistake(e.toString());
      try{
        mvCommentList.clear();
        Response response = await _dio.get('http://159.75.108.178:3000/comment/mv?id=$id&realIP=159.75.108.178');
        Map<String, dynamic> map = json.decode(response.toString());
        List<dynamic> rand = map['hotComments'];
        for (var element in rand) {
          mvCommentList.add(CommentModel.fromJson(element));
        }
      } catch (e) {
        //DeBugMessage.addMistake(e.toString());
      }
    }
  }
}

