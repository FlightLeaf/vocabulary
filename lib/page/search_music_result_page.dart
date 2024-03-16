import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vocabulary/model/music.dart';
import 'package:vocabulary/tools/get_source_tools.dart';
import 'package:vocabulary/tools/audio_play_tools.dart';

import 'dart:convert';
import '../model/search.dart';
import '../tools/sqlite_tools.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key, this.searchWord = '海底', this.isVideo = false, this.url = ''});
  final String searchWord;
  final bool isVideo;
  final String url;

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> with SingleTickerProviderStateMixin{

  final List<String> tabs = ['音乐', '视频'];
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  bool opened = false;
  List<SearchModel> searchModelList = [];

  void search(String word) async {
    String jsonString = await ApiDio.getSearch(word);
    Map<String, dynamic> jsonDio = jsonDecode(jsonString);
    List<dynamic> jsonSong = jsonDio['result']['songs'];
    setState(() {
      for (Map<String, dynamic> json_song_ in jsonSong) {
        searchModelList.add(searchModelFromJson(json_song_));
      }
    });
  }

  List<MusicModel> musicModelList = [];

  List<bool> isLoveState = [];

  @override
  void initState() {
    super.initState();
    musicModelList = AudioPlayerUtil.list;
    _tabController = TabController(vsync: this, length: tabs.length);
    search(widget.searchWord);
    AudioPlayerUtil.positionListener(key: this, listener: (position) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    AudioPlayerUtil.removePositionListener(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !widget.isVideo?AppBar(
        surfaceTintColor: Colors.white,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.searchWord,
            hintStyle: TextStyle(color: Colors.grey[400]), // 提示文本样式
            filled: true, // 设置为true，应用背景颜色
            fillColor: Colors.white, // 背景颜色
            contentPadding: const EdgeInsets.only(
                left: 20,
                top: 10,
                bottom: 10,
                right: 10
            ), // 内边距，增加输入文本与边框的距离
            border: OutlineInputBorder( // 边框样式
              borderRadius: BorderRadius.circular(10), // 圆角边框
            ),
            suffixIcon: IconButton(
              alignment: Alignment.centerLeft,
              icon: const Icon(Icons.search_sharp, color: Colors.black,), // 搜索图标颜色
              onPressed: () async {
                if(_searchController.text.isEmpty) return;
                SqlTools.inSearch(_searchController.text);
                await ApiDio.getSearchWord();
                setState(() {});
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SearchResultPage(
                    searchWord: _searchController.text == ''
                        ? widget.searchWord
                        : _searchController.text,),
                ),);
              },
            ),
          ),
        ),
      ): null,
      body: ListView.builder(
        itemCount: searchModelList.length,
        itemBuilder: (context, index) {
          isLoveState.add(SqlTools.isLoveMusic(searchModelList[index].id.toString()));
          return Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) async {
                    print('$index==============');
                    await ApiDio.getMusic(
                        searchModelList[index].id).then((value) {
                      if (isLoveState[index]) {
                        SqlTools.deLove(
                            searchModelList[index].id.toString().toString());
                        isLoveState[index] = false;
                        ApiDio.getLove();
                        setState(() {});
                      } else {
                        SqlTools.inLoveMusic(value);
                        isLoveState[index] = true;
                        ApiDio.getLove();
                        setState(() {});
                      }
                    });
                  },
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.red,
                  icon: isLoveState[index] ? Icons.favorite_rounded : Icons
                      .favorite_border_rounded,
                  label: '喜欢',
                ),
                SlidableAction(
                  onPressed: (BuildContext context) async {
                    await ApiDio.getMusic(
                        searchModelList[index].id).then((value) {
                      SqlTools.inDownload(value);
                      setState(() {

                      });
                    });
                  },
                  backgroundColor: const Color(0xFF0029A7),
                  foregroundColor: Colors.white,
                  icon: Icons.downloading_rounded,
                  label: '下载',
                ),
              ],
            ),
            child: ListTile(
              //isThreeLine: true,
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 4),
              leading: IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: () async {
                  await ApiDio.getMusic(searchModelList[index].id)
                      .then((value) {
                    if (value.mp3Url != '') {
                      if(widget.isVideo){
                        AudioPlayerUtil.addMusicModel(models: value);
                      }else{
                        AudioPlayerUtil.addMusicModelNext(models: value);
                      }
                    }
                  });
                },
              ),
              title: Text(
                searchModelList[index].name, style: const TextStyle(fontSize: 16),),
              subtitle: Text(
                searchModelList[index].artists.map((artist) => artist.name)
                    .join(', '), style: const TextStyle(fontSize: 12),),
              onTap: () async {
                if(widget.isVideo){
                  showToast('点击收藏');
                }else{
                  await ApiDio.getMusic(searchModelList[index].id)
                      .then((value) {
                    if (value.mp3Url != '') {
                      AudioPlayerUtil.addMusicModel(models: value);
                      AudioPlayerUtil.listPlayerHandle(
                          musicModels: AudioPlayerUtil.list, musicModel: value);
                    }
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}
