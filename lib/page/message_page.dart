import 'dart:async';
import 'dart:collection';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vocabulary/page/deBug_page.dart';
import 'package:vocabulary/page/login_register_page.dart';
import 'package:vocabulary/tools/get_source_tools.dart';
import 'package:vocabulary/tools/login_state_tools.dart';
import 'package:vocabulary/tools/sharedPreferences_tools.dart';
import 'package:vocabulary/widget/music_list.dart';

import '../model/music.dart';
import '../tools/audio_play_tools.dart';
import '../widget/mv_card.dart';

class MessagePage extends StatefulWidget {
  MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  int state = 0;
  String img = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await Future.wait([
        ApiDio.getDownload(),
        ApiDio.getLove(),
        ApiDio.getHistory(),
        ApiDio.getMvHistory()
      ]).then((values) => setState(() {}));
    });
    ApiDio.getDownload();
    ApiDio.getMvHistory();
    AudioPlayerUtil.positionListener(
        key: this,
        listener: (position) {
          if (mounted) {
            setState(() {});
          }
        });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
    AudioPlayerUtil.removePositionListener(this);
  }

  List<List<MusicModel>> title = [
    ApiDio.loveList,
    ApiDio.localList,
    ApiDio.historyList,
  ];

  bool isLove = false;

  bool inProduction = const bool.fromEnvironment('dart.vm.product');

  List<bool> colorState = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white, // 背景色设置为透明
          ),
          collapseMode: CollapseMode.parallax,
        ),
        actions: [
          !inProduction
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DeBugPage(),
                    ));
                  },
                  icon: const Icon(Icons.bug_report_rounded,
                      size: 28, color: Colors.red),
                )
              : IconButton(onPressed: () {}, icon: Container()),
          IconButton(
            onPressed: () {
              showToast('敬请期待-音乐迁移');
            },
            icon: const Icon(Icons.keyboard_control_rounded,
                size: 28, color: Colors.black),
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
      body: RefreshIndicator(
        child: ListView(
          scrollDirection: Axis.vertical, // 使用ListView可以轻松实现滚动
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LoginState.state
                  ? _buildUserMessage(context)
                  : _buildLoginMessage(context),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildMusicEntrySection(),
            ),
            _stateBuild(context),
            SizedBox(
              height: 60,
            ),
          ],
        ),
        onRefresh: () async {
          await Future.wait([
            ApiDio.getDownload(),
            ApiDio.getLove(),
            ApiDio.getHistory(),
            ApiDio.getMvHistory()
          ]).then((values) => setState(() {}));
        },
      ),
    );
  }

  Widget _stateBuild(BuildContext context) {
    List<Container> _list = [
      Container(
        child: Column(
          children: ApiDio.loveList.isEmpty
              ? []
              : ApiDio.loveList
                  .map(
                    (song) => MusicListWidget(state: state, model: song),
                  )
                  .toList(),
        ),
      ),
      Container(
        child: Column(
          children: ApiDio.localList.isEmpty
              ? []
              : ApiDio.localList
                  .map(
                    (song) => MusicListWidget(state: state, model: song),
                  )
                  .toList(),
        ),
      ),
      Container(
        child: Column(
          children: ApiDio.historyList.isEmpty
              ? []
              : ApiDio.historyList
                  .map(
                    (song) => MusicListWidget(state: state, model: song),
                  )
                  .toList(),
        ),
      ),
      Container(
        child: Column(
          children: ApiDio.mvHistory.isEmpty
              ? []
              : ApiDio.mvHistory
                  .map(
                    (song) => MvCard(
                      mvSheet: song,
                      isHistory: true,
                    ),
                  )
                  .toList(),
        ),
      ),
    ];

    return _list[state];
  }

  // 构建喜欢的音乐入口部分
  Widget _buildUserMessage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.grey.shade200,
      ),
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(
        top: 2,
        bottom: 6,
        left: 18,
        right: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              width: 66,
              height: 66,
              child: img == 'NOT_FOUND'
                  ? Image.asset(
                      "assets/app.png",
                      //fit: BoxFit.cover,
                      width: 66,
                      height: 66,
                      alignment: Alignment.topLeft,
                    )
                  : ExtendedImage.network(
                      img,
                      fit: BoxFit.cover,
                      alignment: Alignment.topLeft,
                      cache: true,
                      loadStateChanged: (ExtendedImageState state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            return Image.asset(
                              "assets/app.png",
                              width: 66,
                              height: 66,
                              //fit: BoxFit.fill,
                            );
                          case LoadState.failed:
                            return GestureDetector(
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  Image.asset(
                                    "assets/app.png",
                                    //fit: BoxFit.fill,
                                    width: 66,
                                    height: 66,
                                  ),
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
          Expanded(
              flex: 2,
              child: ListTile(
                  title: Text(DataUtils.getString('user')!),
                  //subtitle: Text(DataUtils.getString('em')!),
                  onTap: () {})),
          Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.exit_to_app_rounded),
                  onPressed: () {
                    LoginState.unLogin();
                    LoginState.state = false;
                    setState(() {

                    });
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLoginMessage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.grey.shade200,
      ),
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(
        top: 2,
        bottom: 6,
        left: 18,
        right: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              width: 66,
              height: 66,
              child: Image.asset(
                "assets/app.png",
                width: 66,
                height: 66,
                //fit: BoxFit.fill,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListTile(title: const Text("请登录"), onTap: () {}),
          ),
          Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.login_rounded),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
                  },
                ),
              )),
        ],
      ),
    );
  }

  // 构建喜欢的音乐入口部分
  Widget _buildMusicEntrySection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.grey.shade200,
      ),
      padding: const EdgeInsets.all(15),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(
        top: 6,
        bottom: 6,
        left: 18,
        right: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: _buildButton('我喜欢', Icons.favorite_sharp,
                state == 0 ? Colors.red : Colors.black45, () {
              state = 0;
              setState(() {});
            }),
          ),
          Expanded(
            child: _buildButton('本地音乐', Icons.folder_rounded,
                state == 1 ? Colors.orange : Colors.black45, () {
              state = 1;
              setState(() {});
            }),
          ),
          Expanded(
            child: _buildButton('音乐历史', Icons.music_note_rounded,
                state == 2 ? Colors.blueAccent : Colors.black45, () {
              state = 2;
              setState(() {});
            }),
          ),
          Expanded(
            child: _buildButton('视频历史', Icons.video_collection_rounded,
                state == 3 ? Colors.green : Colors.black45, () {
              state = 3;
              setState(() {});
            }),
          ),
        ],
      ),
    );
  }

  // 辅助函数，用于创建按钮
  Widget _buildButton(
      String title, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      children: <Widget>[
        IconButton(
          icon: Icon(icon, size: 24, color: color),
          onPressed: onPressed,
        ),
        Text(title, style: TextStyle(fontSize: 12, color: color))
      ],
    );
  }
}
