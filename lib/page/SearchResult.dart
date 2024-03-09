import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:vocabulary/model/music.dart';
import 'package:vocabulary/tools/ApiDio.dart';
import 'package:vocabulary/tools/AudioPlayerTools.dart';

import 'dart:convert';
import '../model/search.dart';

class searchResult extends StatefulWidget {
  const searchResult({super.key, this.searchWord = '海底'});
  final String searchWord;

  @override
  _searchResultState createState() => _searchResultState();
}

class _searchResultState extends State<searchResult> {

  final TextEditingController _searchController = TextEditingController();
  bool opened = false;
  List<SearchModel> searchModelList = [];

  void search(String word) async {

    String jsonString = await ApiDio.getSearch(word);
    Map<String, dynamic> jsonDio = jsonDecode(jsonString);
    List<dynamic> jsonSong = jsonDio['result']['songs'];

    setState(() {
      for(Map<String, dynamic> json_song_ in jsonSong){
        searchModelList.add(searchModelFromJson(json_song_));
      }
    });
  }
  List<MusicModel> musicModelList = [];

  @override
  void initState() {
    super.initState();
    musicModelList = AudioPlayerUtil.list;
    search(widget.searchWord);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.searchWord,
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => searchResult(searchWord: _searchController.text == '' ? widget.searchWord : _searchController.text,),
                ),);
              },
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: searchModelList.length,
        itemBuilder: (context, index) {
          return ListTile(
            isThreeLine: true,
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            leading: Icon(Icons.favorite_border_rounded),
            title: Text(searchModelList[index].name, style: TextStyle(fontSize: 16),),
            subtitle: Text(searchModelList[index].artists.map((artist) => artist.name).join(', '), style: TextStyle(fontSize: 12),),
            trailing: IconButton(
              onPressed: (){
                Scaffold.of(context).showBottomSheet((_) => buildSheet(context,searchModelList[index].id.toString() , searchModelList[index].name, searchModelList[index].artists.map((artist) => artist.name).join(', ')));
              },
              icon:Icon(Ionicons.ellipsis_vertical,size: 18,),
            ),
            onTap: () async {
              await ApiDio.getMp3Model(searchModelList[index].id.toString()).then((value){
                if(value.mp3Url != ''){
                  AudioPlayerUtil.addMusicModel(models: value);
                  AudioPlayerUtil.listPlayerHandle(musicModels: AudioPlayerUtil.list,musicModel: value);
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget buildSheet(BuildContext context,String id, String music, String author) => BottomSheet(
    enableDrag: true,
    elevation: 0,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        )),
    backgroundColor: Colors.blue.shade100,
    onClosing: () => print('onClosing'),
    builder: (_) => (Container(
      width: 500,
      height: 260,
      child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                    child: ListTile(
                      title: Text(music,style: TextStyle(fontSize: 20),),
                      subtitle: Text(author),
                    )
                ),
              ),
              Divider(color: Colors.grey,),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () async{
                              await ApiDio.getMp3Model(id).then((value){
                                if(value.mp3Url != ''){
                                  AudioPlayerUtil.addMusicModel(models: value);
                                  AudioPlayerUtil.listPlayerHandle(musicModels: AudioPlayerUtil.list,musicModel: value);
                                }
                              });
                            },
                            icon: Icon(Icons.play_circle_outline_rounded),
                          ),
                          Center(child: Text('播放')),
                        ],
                      ),

                    ),
                    Expanded(
                      flex: 1,
                      child:
                      Column(
                        children: [
                          IconButton(
                            onPressed: (){},
                            icon: Icon(Icons.favorite_border_rounded),
                          ),
                          Center(child: Text('收藏')),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child:
                      Column(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await ApiDio.getMp3Model(id).then((value){
                                if(value.mp3Url != ''){
                                  AudioPlayerUtil.addMusicModelNext(models: value);
                                }
                              });
                            },
                            icon: Icon(Icons.next_plan_rounded),
                          ),
                          Center(child: Text('下一首播放')),
                        ],
                      ),

                    ),
                    Expanded(
                      flex: 1,
                      child: Column(

                        children: [
                          IconButton(
                            onPressed: (){

                            },
                            icon: Icon(Icons.save_alt),
                          ),
                          Center(child: Text('下载')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey,),
              Expanded(
                flex: 1,
                child: InkWell(
                    onTap: () {
                      opened = false;
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    } ,
                    child: Center(
                      child: Text('关闭',style: TextStyle(fontSize: 16),),
                    )
                ),
              ),
            ],
          )
      ),
    )
    ),
  );

}
