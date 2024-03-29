import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vocabulary/model/mv.dart';
import 'package:vocabulary/tools/get_source_tools.dart';

import 'package:vocabulary/tools/audio_play_tools.dart';
import 'package:vocabulary/tools/sqlite_tools.dart';
import '../model/music.dart';
import '../page/video_player_page.dart';

class MusicListWidget extends StatefulWidget {
  const MusicListWidget({Key? key,required this.state, required this.model}) : super(key: key);
  final int state;
  final MusicModel model;
  @override
  _MusicListWidgetState createState() => _MusicListWidgetState();
}

class _MusicListWidgetState extends State<MusicListWidget> {

  List<List<MusicModel>> title = [
    ApiDio.loveList,
    ApiDio.localList,
    ApiDio.historyList,
  ];

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    AudioPlayerUtil.positionListener(
        key: this,
        listener: (position) {
          setState(() {
            if(widget.model.id == AudioPlayerUtil.musicModel!.id){
              _isPlaying = true;
            }else{
              _isPlaying = false;
            }
          });
        });
  }

  @override
  void dispose() {
    super.dispose();
    AudioPlayerUtil.removePositionListener(this);
    AudioPlayerUtil.removeStatusListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: Slidable(
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (BuildContext context) async {
                setState(() {
                  if (widget.state == 2) {
                    SqlTools.deTime(widget.model.id.toString());
                    ApiDio.getHistory();
                    setState(() {});
                  } else if (widget.state == 0) {
                    SqlTools.deLove(widget.model.id.toString());
                    ApiDio.getLove();
                    setState(() {});
                  } else {
                    SqlTools.deLocal(widget.model.id.toString());
                    ApiDio.getDownload();
                    setState(() {});
                  }
                });
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: widget.state == 1 ? '删除' : '移除',
            ),
            SlidableAction(
              onPressed: (BuildContext context) {
                if (widget.state == 1) {
                  showToast('已下载');
                } else {
                  SqlTools.inDownload(widget.model);
                  ApiDio.getDownload();
                  setState(() {});
                }
              },
              backgroundColor: const Color(0xFF0029A7),
              foregroundColor: Colors.white,
              icon: Icons.downloading_rounded,
              label: widget.state == 1 ? '下载' : '下载',
            ),
          ],
        ),
        child: ListTile(
          isThreeLine: true,
          dense: true,
          title: Text(
            widget.model.name,
            style: TextStyle(
                fontSize: 16,
                color: _isPlaying ? Colors.blue : Colors.black54),
          ),
          subtitle: Text(
            widget.model.author,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: widget.state == 2
              ? IconButton(
              onPressed: () {
                if (SqlTools.isLoveMusic(
                    widget.model.id.toString())) {
                  SqlTools.deLove(
                      widget.model.id.toString());
                  ApiDio.getLove();
                  setState(() {});
                } else {
                  SqlTools.inLoveMusic(widget.model);
                  ApiDio.getLove();
                  setState(() {});
                }
              },
              icon: Icon(
                Icons.favorite,
                color: SqlTools.isLoveMusic(
                    widget.model.id.toString())
                    ? Colors.red
                    : Colors.grey,
              ))
              : Container(
            width: 0,
          ),
          onTap: () {
            AudioPlayerUtil.listPlayerHandle(
                musicModels: title[widget.state], musicModel: widget.model);
            setState(() {});
          },
        ),
      ),
    );
  }

}
