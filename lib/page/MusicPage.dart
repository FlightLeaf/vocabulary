import 'package:flutter/material.dart';
import 'package:vocabulary/tools/ApiDio.dart';
import 'package:vocabulary/widget/MvCard.dart';

import '../Widget/MusicCard.dart';
import '../widget/Banner.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    final width =size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('推荐'),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white, // 背景色设置为透明
          ),
          collapseMode: CollapseMode.parallax,
        ),
      ),
      body: RefreshIndicator(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          reverse: false,
          child: Column(
            children: [
              Container(
                  height: width*0.38,
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
                  )
              ),
              Container(
                margin: const EdgeInsets.only(left: 17),
                child: Row(
                  children: [
                    const Text('今日推荐',style: TextStyle(fontSize: 18),),
                    Container(
                      width: 15,
                    ),
                  ],
                ),
              ),
              Container(
                height: 189,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: false,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: ApiDio.musicSheetList.isEmpty? [] :ApiDio.musicSheetList.map((song) =>
                        MusicCard(musicSheet: song, isOne: false),
                    ).toList(),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 17),
                child: Row(
                  children: [
                    const Text(' MV推荐',style: TextStyle(fontSize: 18),),
                    Container(
                      width: 15,
                    ),
                  ],
                ),
              ),
              Container(
                height: 2400,
                margin: const EdgeInsets.only(top: 4),
                child: Column(
                  children: ApiDio.newMvList.isEmpty? [] :ApiDio.newMvList.map((song) =>
                      MvCard(mvSheet: song),
                  ).toList(),
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

