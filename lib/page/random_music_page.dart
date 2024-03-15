import 'package:audioplayers/audioplayers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:vocabulary/widget/random_music_card.dart';

import 'package:vocabulary/tools/audio_play_tools.dart';

import '../model/music.dart';
import '../tools/api_dio_get_source_tools.dart';
import '../tools/sqlite_tools.dart';
import 'music_comment.dart';


class RandPage extends StatefulWidget {
  RandPage({Key? key}) : super(key: key);
  @override
  _RandPageState createState() => _RandPageState();
}

class _RandPageState extends State<RandPage> {

  List<CardChildPage> cards = [
    CardChildPage(),
    CardChildPage(),
  ];
  late CardSwiperController _cardSwiperController;

  @override
  void initState() {
    _cardSwiperController = CardSwiperController();
    super.initState();
    AudioPlayerUtil.positionListener(key: this, listener: (position){
      setState(() {});
    });
  }

  @override
  void dispose() {
    _cardSwiperController.dispose();
    AudioPlayerUtil.removePositionListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    final width =size.width;
    return PopScope(
      onPopInvoked: (state){
        if(AudioPlayerUtil.state == PlayerState.paused){

        }else{
          AudioPlayerUtil.listPlayerHandle(musicModels: ApiDio.randomList, musicModel:  ApiDio.randomList[ApiDio.randomList.length-2]);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: Colors.white, // 背景色设置为透明
            ),
            collapseMode: CollapseMode.parallax,

          ),
          actions: [
            InkWell(
              child: Image.asset('assets/comment.png',width: width*0.08,),
              onTap: () async {
                await ApiDio.getComment(ApiDio.randomList[ApiDio.randomList.length-2].id.toString());
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CommentList(musicModel: ApiDio.randomList[ApiDio.randomList.length-2]),
                ));
              },
            ),
            SizedBox(width: 15,)
          ],
        ),
        body: AudioPlayerUtil.musicModel == null?Container():Flex(
          direction: Axis.vertical,
          children:[
            Flexible(
              child: CardSwiper(
                controller: _cardSwiperController,
                cardsCount: cards.length,
                cardBuilder: (context, index, percentThresholdX, percentThresholdY) => cards[index],
                onSwipe: (current,next,c) async {
                  print('current: $current, next: $next');
                  await ApiDio.getRandomMusic(1).then((value){
                    AudioPlayerUtil.listPlayerHandle(musicModels: ApiDio.randomList, musicModel:  ApiDio.randomList[ApiDio.randomList.length-2]);
                  });
                  return true;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
