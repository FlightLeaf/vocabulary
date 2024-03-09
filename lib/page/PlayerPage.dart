import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ionicons/ionicons.dart';
import 'package:vocabulary/model/music.dart';
import 'package:vocabulary/page/CommentPage.dart';
import 'package:vocabulary/page/PlayList.dart';
import 'package:vocabulary/tools/ApiDio.dart';

import '../tools/AudioPlayerTools.dart';
import '../widget/AudioSlider.dart';

class MusicPlayer extends StatefulWidget {
  MusicPlayer({super.key});

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {

  bool _playing = (AudioPlayerUtil.state == PlayerState.playing);
  String picUrl = 'https://p3.music.126.net/YRFYXG6YaJfTyy_mQntS4A==/109951164799337803.jpg?param=300y300';
  String name = 'Happy';
  String author = '周杰伦';
  late MusicModel musicModel;

  late final ScrollController _scrollController;
  bool opened = false;

  String currentDuration = "00:00";

  @override
  void initState() {
    musicModel = AudioPlayerUtil.musicModel!;
    ApiDio.getComment(musicModel.id.toString());
    super.initState();
    _scrollController = ScrollController();
    ApiDio.getWord(AudioPlayerUtil.musicModel!.id.toString());
    AudioPlayerUtil.statusListener(key: this, listener: (sate){
      if(mounted){
        setState(() {
          ApiDio.getWord(AudioPlayerUtil.musicModel!.id.toString());
          musicModel = AudioPlayerUtil.musicModel!;
          name = AudioPlayerUtil.musicModel!.name.toString();
          author = AudioPlayerUtil.musicModel!.author.toString();
        });
      }
    });
    AudioPlayerUtil.positionListener(key: this, listener: (position){
      currentDuration = _updateDuration(position);
      ApiDio.getWord(AudioPlayerUtil.musicModel!.id.toString());
      List<String> keys = ApiDio.lyricsMap.keys.toList(); // 将键转换为列表
      int index = keys.indexOf(currentDuration.toString()); // 找到键的索引
      if(index!= -1){
        scrollToIndex(index);
      }
      setState(() {});
    });
  }

  String _updateDuration(int second){
    int min = second ~/ 60;
    int sec = second % 60;
    String minString = min < 10 ? "0$min" : min.toString();
    String secString = sec < 10 ? "0$sec" : sec.toString();
    return minString+":"+secString;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    AudioPlayerUtil.removePositionListener(this);
    AudioPlayerUtil.removeStatusListener(this);
  }

  void scrollToIndex(int index) {
    final itemExtent = 30.0; // 每个item的高度
    _scrollController.animateTo(index * itemExtent, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    final width =size.width;
    final height =size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_downward_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.grey[200], // 背景色设置为透明
          ),
          collapseMode: CollapseMode.parallax,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.comment_rounded),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CommentList(musicModel: AudioPlayerUtil.musicModel!),
              ));
            },
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Image.network(
                  width: width*0.6,
                  musicModel.picUrl!
              ),
            ),

            SizedBox(height: 20),
            Text(
              textAlign: TextAlign.center,
              musicModel.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              musicModel.author,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Container(
              height: 160,
              child: ListWheelScrollView(
                controller: _scrollController,
                perspective: 0.01,
                itemExtent: 30,
                useMagnifier: true,
                magnification: 1.3,
                children: ApiDio.lyricsMap.entries.map((value) => _buildItem(value.value)).toList(),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: AudioSlider(),
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border_rounded,size: 26,),
                  onPressed: () async {

                  },
                ),
                IconButton(
                  icon: Icon(Icons.skip_previous_rounded,size: 42,),
                  onPressed: () async{
                    AudioPlayerUtil.previousMusic();
                    await ApiDio.getWord(AudioPlayerUtil.musicModel!.id.toString());

                    setState(() {
                      musicModel = AudioPlayerUtil.musicModel!;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(_playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,size: 62,color: Colors.blue,),
                  onPressed: () async {
                    AudioPlayerUtil.playerHandle(model: musicModel);
                    musicModel = AudioPlayerUtil.musicModel!;
                    await ApiDio.getWord(AudioPlayerUtil.musicModel!.id.toString());
                    setState(() {
                      _playing = (AudioPlayerUtil.state == PlayerState.playing);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.skip_next_rounded,size: 42,),
                  onPressed: () async {
                    AudioPlayerUtil.nextMusic();
                    await ApiDio.getWord(AudioPlayerUtil.musicModel!.id.toString());
                    setState(() {
                      musicModel = AudioPlayerUtil.musicModel!;
                    });
                  },
                ),
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: Icon(Icons.queue_music_rounded,size: 30,),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => playList(),
                        ));
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildItem(String text) {
    return Container(
      child: Center(
        child: Text(text, style: TextStyle(fontSize: 14)),
      ),
    );
  }
}
