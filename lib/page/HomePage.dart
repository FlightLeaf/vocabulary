import 'package:audioplayers/audioplayers.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:marquee/marquee.dart';
import 'package:vocabulary/model/music.dart';
import 'package:vocabulary/page/PlayingListPage.dart';

import '../tools/ApiDio.dart';
import '../tools/AudioPlayerTools.dart';
import 'MusicPage.dart';
import 'Message.dart';
import 'PlayerPage.dart';
import 'SearchPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  List<Widget> page = [MusicPage(), SearchPage(), MessagePage()];
  late AnimationController _ctrl;
  late bool _playing = false;
  String name_author = 'Happy!';
  String img = 'NOT_FOUND';
  bool opened = false;

  @override
  void initState() {
    ApiDio.getHotList();
    ApiDio.getSearchWord();
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    AudioPlayerUtil.statusListener(key: this, listener: (state) {
      if ((AudioPlayerUtil.musicModel != null)) { // 为当前资源
        if (mounted) {
          setState(() {
            _playing = state == PlayerState.playing;
            String author = AudioPlayerUtil.musicModel?.author ?? 'Happy!';
            name_author = AudioPlayerUtil.musicModel?.name ?? 'Happy!' + ' - ' + author;
            img = AudioPlayerUtil.musicModel?.picUrl ?? 'NOT_FOUND';
            //_ctrl.repeat(reverse: false);
          });
        }
      } else { // 不是当前资源，若当前正在播放，则暂停
        if (_playing == true) {
          if (mounted) {
            setState(() {
              _playing == false;
            });
          }
        }
      }
      if (_playing) {
        _ctrl.repeat(reverse: false);
      }else{
        _ctrl.stop();
      }
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    final width =size.width;
    final height =size.height;
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 12,
                    child: Container(
                      child: page[_currentIndex],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: CustomNavigationBar(
                        iconSize: 35.0,
                        selectedColor: Colors.blue,
                        strokeColor: Colors.blue,
                        unSelectedColor: Colors.black,
                        backgroundColor: Colors.white,
                        elevation: 40,
                        scaleFactor: 0.4,
                        items: [
                          CustomNavigationBarItem(
                            icon: const Icon(Icons.music_note_rounded),
                          ),
                          CustomNavigationBarItem(
                            icon: const Icon(Icons.search_rounded),
                          ),
                          CustomNavigationBarItem(
                            icon: const Icon(Icons.person_rounded),
                          ),
                        ],
                        currentIndex: _currentIndex,
                        opacity: 0.5,
                        onTap: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Expanded(
                  flex: 20,
                  child: Container(

                  ),
                ),
                Expanded(
                  flex: 11,
                  child: Container(
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Container(
                          width: width,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          //padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(flex:1, child: Container()),
                              Expanded(
                                flex: 24,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if(AudioPlayerUtil.list.isEmpty) return;
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => MusicPlayer(),
                                      ));
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      left: width*0.18+8,
                                    ),
                                    child: Marquee(
                                      text: name_author,
                                      blankSpace: 20.0,
                                      velocity: 36.0,
                                      pauseAfterRound: Duration(seconds: 0),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: InkWell(
                                  child: Container(
                                    child: Icon(
                                      Icons.skip_previous_rounded, size: 24, color: Colors.white,
                                    ),
                                  ),
                                  onTap: (){
                                    print('上一曲');
                                    AudioPlayerUtil.previousMusic();
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: InkWell(
                                  child: Container(
                                    child: Icon(
                                      !_playing?Icons.play_circle_outline_rounded: Icons.pause_circle_outline_rounded,
                                      size: width*0.1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: (){
                                    AudioPlayerUtil.playerHandle(model: AudioPlayerUtil.musicModel!);
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: InkWell(
                                  child: Container(
                                    child: Icon(
                                      Icons.skip_next_rounded, size: 24, color: Colors.white,
                                    ),
                                  ),
                                  onTap: (){
                                    print('下一曲');
                                    AudioPlayerUtil.nextMusic();
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Builder(
                                  builder: (BuildContext context) {
                                    return Scaffold(
                                      backgroundColor: Colors.transparent,
                                      body: InkWell(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.queue_music_rounded, size: 24, color: Colors.white,
                                          ),
                                        ),
                                        onTap: () {
                                          //if(AudioPlayerUtil.isListPlayer)print('==========');
                                          if(AudioPlayerUtil.list.isEmpty) return;
                                          Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => PlayingListPage(),
                                          ));
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Expanded(flex:1, child: Container()),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20,
                              bottom: 5
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              RotationTransition(
                                turns: CurvedAnimation(
                                  parent: _ctrl,
                                  curve: Curves.linear,
                                ),
                                child: ClipOval(
                                  child: img == 'NOT_FOUND'?Image.asset(
                                    'assets/music.png',
                                    width: 66,
                                    height: 66,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topLeft,
                                  ): Image.network(
                                    img,
                                    width: 66,
                                    height: 66,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topLeft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

}
