import 'package:audioplayers/audioplayers.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:vocabulary/page/shazam_encore_page.dart';
import 'package:vocabulary/page/playing_list_page.dart';
import 'package:vocabulary/page/search_page.dart';

import '../tools/get_source_tools.dart';
import '../tools/audio_play_tools.dart';
import 'music_page.dart';
import 'message_page.dart';
import 'audio_play_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  List<Widget> page = [
    const MusicPage(),
    const SearchPage(),
    const IdentifyPage(),
    MessagePage()
  ];
  late AnimationController _ctrl;
  late bool _playing = false;
  String nameAuthor = 'Happy!';
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
    AudioPlayerUtil.statusListener(
        key: this,
        listener: (state) {
          if ((AudioPlayerUtil.musicModel != null)) {
            if (mounted) {
              setState(() {
                _playing = state == PlayerState.playing;
                String author = AudioPlayerUtil.musicModel?.author ?? 'Happy!';
                nameAuthor =
                    '${AudioPlayerUtil.musicModel?.name} - ${AudioPlayerUtil.musicModel!.author}' ??
                        'Happy! - $author';
                img = AudioPlayerUtil.musicModel?.picUrl ?? 'NOT_FOUND';
                //_ctrl.repeat(reverse: false);
              });
            }
          } else {
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
          } else {
            _ctrl.stop();
          }
          setState(() {});
        });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 30,
                  child: Container(
                    child: page[_currentIndex],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: CustomNavigationBar(
                      iconSize: 28.0,
                      selectedColor: Colors.blue,
                      strokeColor: Colors.blue,
                      unSelectedColor: Colors.black,
                      backgroundColor: Colors.white,
                      elevation: 40,
                      scaleFactor: 0.4,
                      items: [
                        CustomNavigationBarItem(
                          icon: const Icon(Icons.home_rounded),
                          selectedIcon: const Icon(Icons.houseboat_rounded),
                          title:
                              const Text('首页', style: TextStyle(fontSize: 12)),
                          selectedTitle: const Text('首页',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 12)),
                        ),
                        CustomNavigationBarItem(
                          icon: const Icon(Icons.search_rounded),
                          selectedIcon: const Icon(Icons.manage_search_rounded),
                          title:
                              const Text('搜索', style: TextStyle(fontSize: 12)),
                          selectedTitle: const Text('搜索',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 12)),
                        ),
                        CustomNavigationBarItem(
                          icon: const Icon(Icons.sensors_rounded),
                          selectedIcon: const Icon(Icons.music_note_rounded),
                          title:
                              const Text('识曲', style: TextStyle(fontSize: 12)),
                          selectedTitle: const Text('识曲',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 12)),
                        ),
                        CustomNavigationBarItem(
                          icon: const Icon(Icons.person_rounded),
                          selectedIcon: const Icon(Icons.person_pin_rounded),
                          title:
                              const Text('我的', style: TextStyle(fontSize: 12)),
                          selectedTitle: const Text('我的',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 12)),
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
                child: Container(),
              ),
              Expanded(
                flex: 11,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      width: width,
                      height: height * 0.052,
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
                          Expanded(flex: 1, child: Container()),
                          Expanded(
                            flex: 24,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (AudioPlayerUtil.list.isEmpty) return;
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const MusicPlayer(),
                                  ));
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: width * 0.18 + 8,
                                ),
                                child: Marquee(
                                  text: nameAuthor,
                                  blankSpace: 20.0,
                                  velocity: 36.0,
                                  pauseAfterRound: const Duration(seconds: 0),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: InkWell(
                              child: const Icon(
                                Icons.skip_previous_rounded,
                                color: Colors.white,
                              ),
                              onTap: () {
                                print('上一曲');
                                AudioPlayerUtil.previousMusic();
                              },
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: InkWell(
                              child: Icon(
                                !_playing
                                    ? Icons.play_circle_outline_rounded
                                    : Icons.pause_circle_outline_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                              onTap: () {
                                AudioPlayerUtil.playerHandle(
                                    model: AudioPlayerUtil.musicModel!);
                              },
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: InkWell(
                              child: const Icon(
                                Icons.skip_next_rounded,
                                color: Colors.white,
                              ),
                              onTap: () {
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
                                      child: const Icon(
                                        Icons.queue_music_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () {
                                      //if(AudioPlayerUtil.isListPlayer)print('==========');
                                      if (AudioPlayerUtil.list.isEmpty) {
                                        return;
                                      }
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            const PlayingListPage(),
                                      ));
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(flex: 1, child: Container()),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20, bottom: 5),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          RotationTransition(
                            turns: CurvedAnimation(
                              parent: _ctrl,
                              curve: Curves.linear,
                            ),
                            child: ClipOval(
                              child: img == 'NOT_FOUND'
                                  ? Image.asset(
                                      "assets/app.png",
                                      width: 66,
                                      height: 66,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topLeft,
                                    )
                                  : ExtendedImage.network(
                                      img,
                                      width: width * 0.183,
                                      height: width * 0.183,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topLeft,
                                      cache: true,
                                      loadStateChanged:
                                          (ExtendedImageState state) {
                                        switch (state.extendedImageLoadState) {
                                          case LoadState.loading:
                                            return Image.asset(
                                              "assets/app.png",
                                              fit: BoxFit.fill,
                                            );
                                          case LoadState.failed:
                                            return GestureDetector(
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: <Widget>[
                                                  Image.asset(
                                                    "assets/app.png",
                                                    fit: BoxFit.fill,
                                                  ),
                                                  const Positioned(
                                                    bottom: 0.0,
                                                    left: 0.0,
                                                    right: 0.0,
                                                    child: Text(
                                                      "load image failed, click to reload",
                                                      textAlign:
                                                          TextAlign.center,
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
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
    );
  }
}
