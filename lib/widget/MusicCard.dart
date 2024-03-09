import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:vocabulary/tools/AudioPlayerTools.dart';

import '../model/music.dart';
import '../tools/ApiDio.dart';


class MusicCard extends StatefulWidget {
  MusicCard({Key? key,required this.musicSheet, required this.isOne}) : super(key: key);

  final MusicModel musicSheet ;
  final bool isOne;

  @override
  _MusicCardState createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {

  bool _playing = false;

  @override
  void initState() {
    super.initState();
    AudioPlayerUtil.statusListener(key: this, listener: (state) {
      if ((AudioPlayerUtil.musicModel != null) && (AudioPlayerUtil.musicModel!.mp3Url == widget.musicSheet.mp3Url)) { // 为当前资源
        if (mounted) {
          setState(() {
            _playing = (state == PlayerState.playing);
          });
        }
      } else { // 不是当前资源，若当前正在播放，则暂停
        if (_playing == true) {
          if (mounted) {
            setState(() {
              _playing = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    final width =size.width;
    final height =size.height;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      elevation: 0,
      child: Container(
        color: Colors.white,
        width: 130,
        height: 180,
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      widget.musicSheet.picUrl!,
                      fit: BoxFit.fill,
                    ),
                    InkWell(
                      child: Container(
                        margin: const EdgeInsets.only(
                            right: 5,
                            bottom: 5
                        ),
                        child: Icon(
                            _playing?Icons.pause_circle_outline_rounded :Icons.play_circle_outline_rounded,
                            size: 66,
                            color: Colors.white70
                        ),
                      ),
                      onTap: () async {
                        ApiDio.getWord(widget.musicSheet.id.toString());
                        AudioPlayerUtil.listPlayerHandle(musicModels:widget.isOne?ApiDio.fromSheetList:ApiDio.musicSheetList, musicModel: widget.musicSheet);
                        ApiDio.getNewMV();
                      },
                    ),
                  ],
                )
            ),
            Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(

                  ),
                ),
                Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Expanded(
                              flex:10,
                              child: Container(
                                  alignment: Alignment.center,
                                  child: Text(widget.musicSheet.name)
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                )
              ],
            ),
          ],
        ),
      ),

    );
  }
}
