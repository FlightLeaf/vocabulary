import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:vocabulary/tools/audio_play_tools.dart';

import '../model/music.dart';
import '../tools/get_source_tools.dart';
import '../tools/sqlite_tools.dart';


class CardChildPage extends StatefulWidget {
  const CardChildPage({Key? key,}) : super(key: key);

  @override
  _CardChildPageState createState() => _CardChildPageState();
}

class _CardChildPageState extends State<CardChildPage> {

  bool _playing = (AudioPlayerUtil.state == PlayerState.playing);
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
    init();
    super.initState();
    _scrollController = ScrollController();
    ApiDio.getWord(AudioPlayerUtil.musicModel!.id.toString());
    AudioPlayerUtil.statusListener(key: this, listener: (sate){
      if(mounted){
        setState(() {
          ApiDio.getWord(AudioPlayerUtil.musicModel!.id.toString());
          musicModel = AudioPlayerUtil.musicModel!;
        });
      }
    });
    AudioPlayerUtil.positionListener(key: this, listener: (position){
      init();
      musicModel = AudioPlayerUtil.musicModel!;
      _playing = (AudioPlayerUtil.state == PlayerState.playing);
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
    return "$minString:$secString";
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    AudioPlayerUtil.removePositionListener(this);
    AudioPlayerUtil.removeStatusListener(this);
  }

  void scrollToIndex(int index) {
    const itemExtent = 36.0; // 每个item的高度
    _scrollController.animateTo(index * itemExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    final width =size.width;
    final height =size.height;
    return Center(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: Container(
          height: height * 0.80,
          width: width*0.83,
          color: Colors.grey.shade100,
          child: Column(
            children: [
              ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: ExtendedImage.network(
                    musicModel.picUrl!,
                    width: width*0.83,
                    height: width*0.83,
                    fit: BoxFit.fill,
                    cache: true,
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return Image.asset(
                            "assets/music.gif",
                          );
                        case LoadState.failed:
                          return GestureDetector(
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                Image.asset(
                                  "assets/failed.jpg",
                                  fit: BoxFit.fill,
                                ),
                                const Positioned(
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
                        case LoadState.completed:
                          null;
                      }
                      return null;
                    },
                  )
              ),
              const SizedBox(height: 5,),
              Column(
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    musicModel.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    musicModel.author,
                    style: const TextStyle(fontSize: 14, ),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.17,
                child: ListWheelScrollView(
                  controller: _scrollController,
                  perspective: 0.01,
                  itemExtent: 36,
                  useMagnifier: true,
                  magnification: 1.5,
                  children: ApiDio.lyricsMap.entries.map((value) => _buildItem(value.value)).toList(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: isLove?const Icon(Icons.favorite_rounded, size: 34, color: Colors.red,):const Icon(Icons.favorite,size: 34,),
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
                  SizedBox(width: width*0.05,),
                  IconButton(
                    icon: Icon(_playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,size: 66,color: Colors.green,),
                    onPressed: () async {
                      AudioPlayerUtil.listPlayerHandle(musicModels: ApiDio.randomList, musicModel: musicModel);
                      await ApiDio.getWord(AudioPlayerUtil.musicModel!.id.toString());
                      setState(() {
                        _playing = (AudioPlayerUtil.state == PlayerState.playing);
                      });
                    },
                  ),
                  SizedBox(width: width*0.05,),
                  IconButton(
                    icon: const Icon(Icons.share_rounded,size: 34,),
                    onPressed: () {

                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildItem(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 10),
        softWrap: true,
        //overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
