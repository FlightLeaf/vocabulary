import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vocabulary/tools/get_source_tools.dart';
import 'package:vocabulary/tools/sqlite_tools.dart';

import '../model/music.dart';
import '../tools/audio_play_tools.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  int state = 0;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    ApiDio.getDownload();
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
    super.dispose();
    AudioPlayerUtil.removePositionListener(this);
  }

  List<List<MusicModel>> title = [
    ApiDio.loveList,
    ApiDio.localList,
    ApiDio.historyList
  ];

  bool isLove = false;

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
      ),
      body: ListView(
        scrollDirection: Axis.vertical, // 使用ListView可以轻松实现滚动
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildMusicEntrySection(),
          ),
          _buildList(context),
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
      padding: const EdgeInsets.all(26),
      alignment: Alignment.center,
      margin: const EdgeInsets.all(12),
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
            child: _buildButton('播放记录', Icons.history_rounded,
                state == 2 ? Colors.blueAccent : Colors.black45, () {
              state = 2;
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

  Widget _buildList(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: title[state].length,
        itemBuilder: (context, index) {
          if (AudioPlayerUtil.list.isEmpty ||
              AudioPlayerUtil.musicModel == null) {
            _isPlaying = false;
          } else {
            if (AudioPlayerUtil.musicModel!.id == title[state][index].id) {
              _isPlaying = true;
            } else {
              _isPlaying = false;
            }
          }
          return Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) async {
                    setState(() {
                      if (state == 2) {
                        SqlTools.deTime(title[state][index].id.toString());
                        ApiDio.getHistory();
                        setState(() {});
                      } else if (state == 0) {
                        SqlTools.deLove(title[state][index].id.toString());
                        ApiDio.getLove();
                        setState(() {});
                      } else {
                        SqlTools.deLocal(title[state][index].id.toString());
                        ApiDio.getDownload();
                        setState(() {});
                      }
                    });
                  },
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: state == 1 ? '删除' : '移除',
                ),
                SlidableAction(
                  onPressed: (BuildContext context) {
                    if (state == 1) {
                      showToast('已下载');
                    } else {
                      SqlTools.inDownload(title[state][index]);
                      ApiDio.getDownload();
                      setState(() {});
                    }
                  },
                  backgroundColor: const Color(0xFF0029A7),
                  foregroundColor: Colors.white,
                  icon: Icons.downloading_rounded,
                  label: state == 1 ? '下载' : '下载',
                ),
              ],
            ),
            child: ListTile(
              isThreeLine: true,
              dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
              title: Text(
                title[state][index].name,
                style: TextStyle(
                    fontSize: 16,
                    color: _isPlaying ? Colors.blue : Colors.black54),
              ),
              subtitle: Text(
                title[state][index].author,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: state == 2
                  ? IconButton(
                      onPressed: () {
                        if (SqlTools.isLoveMusic(
                            title[state][index].id.toString())) {
                          SqlTools.deLove(
                              title[state][index].id.toString().toString());
                          ApiDio.getLove();
                          setState(() {});
                        } else {
                          SqlTools.inLoveMusic(title[state][index]);
                          ApiDio.getLove();
                          setState(() {});
                        }
                      },
                      icon: Icon(
                        Icons.favorite,
                        color: SqlTools.isLoveMusic(
                                title[state][index].id.toString())
                            ? Colors.red
                            : Colors.grey,
                      ))
                  : Container(
                      width: 0,
                    ),
              onTap: () {
                AudioPlayerUtil.listPlayerHandle(
                    musicModels: title[state], musicModel: title[state][index]);
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
}
