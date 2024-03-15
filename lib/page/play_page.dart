import 'package:audioplayers/audioplayers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ionicons/ionicons.dart';
import 'package:vocabulary/model/music.dart';
import 'package:vocabulary/page/music_comment.dart';
import 'package:vocabulary/page/playing_list_page.dart';
import 'package:vocabulary/tools/api_dio_get_source_tools.dart';
import 'package:vocabulary/tools/sqlite_tools.dart';

import '../tools/audio_play_tools.dart';
import '../widget/audio_slider.dart';

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
  bool isLove = false;

  void init()  {
    isLove =  SqlTools.isLoveMusic(musicModel.id.toString());
  }

  @override
  void initState() {
    musicModel = AudioPlayerUtil.musicModel!;
    ApiDio.getComment(musicModel.id.toString());
    init();
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
      init();
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

  int next = 0;

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
          InkWell(
            child: Image.asset('assets/comment.png',width: width*0.08,),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CommentList(musicModel: AudioPlayerUtil.musicModel!),
              ));
            },
          ),
          SizedBox(width: 15,)
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 12,
              child:ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child:ExtendedImage.network(
                  musicModel.picUrl!,
                  fit: BoxFit.cover,
                  alignment: Alignment.topLeft,
                  cache: true,
                  loadStateChanged: (ExtendedImageState state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                        return Image.asset(
                          "assets/app.png",
                          fit: BoxFit.fill,
                        );
                        break;
                      case LoadState.failed:
                        return GestureDetector(
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Image.asset(
                                "assets/app.png",
                                fit: BoxFit.fill,
                              ),
                              Positioned(
                                bottom: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Text(
                                  "load image failed, click to reload",
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            state.reLoadImage();
                          },
                        );
                        break;
                      case LoadState.completed:
                        null;
                    }
                    return null;
                  },
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child:Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          musicModel.name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: isLove?Icon(Icons.favorite_rounded, size: 20, color: Colors.red,):Icon(Icons.favorite_border_rounded,size: 26,),
                          onPressed: () async {
                            if(isLove){
                              SqlTools.deLove(musicModel.id.toString());
                              isLove = false;
                              ApiDio.getLove();
                              setState(() {

                              });
                            }else{
                              SqlTools.inLoveMusic(musicModel);
                              isLove = true;
                              ApiDio.getLove();
                              setState(() {

                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Text(
                      musicModel.author,
                      style: TextStyle(fontSize: 16,),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 9,
              child:Container(
                child: ListWheelScrollView(
                  controller: _scrollController,
                  perspective: 0.01,
                  itemExtent: 30,
                  useMagnifier: true,
                  magnification: 1.3,
                  children: ApiDio.lyricsMap.entries.map((value) => _buildItem(value.value)).toList(),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child:Container(
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: AudioSlider(),
              ),
            ),
            Expanded(
              flex: 4,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: switch(AudioPlayerUtil.nextState){
                      NextState.sequential => Icon(Icons.loop_rounded),
                      NextState.random => Icon(Icons.shuffle_rounded),
                      NextState.single => Icon(Icons.repeat_one_rounded),
                    },
                    onPressed: () {
                      next = next + 1;
                      switch (next) {
                        case 1:
                          AudioPlayerUtil.changeNextState(NextState.random);
                          setState(() {});
                          break;
                        case 2:
                          AudioPlayerUtil.changeNextState(NextState.single);
                          setState(() {});
                          break;
                        case 3:
                          AudioPlayerUtil.changeNextState(NextState.sequential);
                          setState(() {});
                          next = 0;
                          break;
                      }
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
                    icon: Icon(_playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,size: 58,color: Colors.green,),
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
                  IconButton(
                    icon: Icon(Icons.queue_music_rounded,size: 30,),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PlayingListPage(),
                      ));
                    },
                  ),
                ],
              ),
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
