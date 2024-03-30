import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vocabulary/tools/get_source_tools.dart';
import 'package:vocabulary/tools/audio_play_tools.dart';
import 'package:vocabulary/tools/temp.dart';
import 'package:vocabulary/widget/mv_card.dart';

import '../Widget/music_card.dart';
import '../widget/banner_card.dart';
import 'random_music_page.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('推荐'),
        flexibleSpace: const FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
        ),
        actions: [
          IconButton(
              onPressed: (){
                try {
                  if (AudioPlayerUtil.state == PlayerState.playing &&
                      AudioPlayerUtil.musicModel!.id ==
                          ApiDio.randomList.first.id) {
                  } else {
                    AudioPlayerUtil.playerHandle(model: ApiDio.randomList.first);
                  }
                } catch (e) {
                  print(e);
                } finally {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => RandPage()));
                }
              },
              icon: const Icon(Icons.library_music_rounded,size: 28,color: Colors.blue),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          reverse: false,
          child: Column(
            children: [
              Container(
                  height: width * 0.38,
                  padding: const EdgeInsets.all(3),
                  margin: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    bottom: 5,
                  ),
                  alignment: Alignment.center,
                  child: const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: BannerPage(),
                  )),
              Container(
                margin: const EdgeInsets.only(left: 17),
                child: Row(
                  children: [
                    const Text(
                      '今日推荐',
                      style: TextStyle(fontSize: 18),
                    ),
                    Container(
                      width: 15,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: false,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: ApiDio.musicSheetList.isEmpty
                        ? []
                        : ApiDio.musicSheetList
                            .map(
                              (song) =>
                                  MusicCard(musicSheet: song, isOne: false),
                            )
                            .toList(),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 17),
                child: Row(
                  children: [
                    const Text(
                      ' MV推荐',
                      style: TextStyle(fontSize: 18),
                    ),
                    Container(
                      width: 14,
                    ),
                  ],
                ),
              ),
              Container(
                height: width * 0.618 * 10.3,
                margin: const EdgeInsets.only(top: 4),
                child: Column(
                  children: ApiDio.newMvList.isEmpty
                      ? []
                      : ApiDio.newMvList
                          .map(
                            (song) => MvCard(mvSheet: song),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
        onRefresh: () async {
          await Future.wait([
            ApiDio.getBan(),
            ApiDio.getSheet(),
          ]).then((values) => setState(() {}));
        },
      ),
    );
  }
}
