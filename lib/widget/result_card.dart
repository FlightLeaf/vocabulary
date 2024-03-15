import 'package:audioplayers/audioplayers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:vocabulary/tools/audio_play_tools.dart';

import '../model/music.dart';
import '../tools/api_dio_get_source_tools.dart';


class ResultCard extends StatefulWidget {
  ResultCard({Key? key,required this.musicSheet}) : super(key: key);

  final MusicModel musicSheet ;
  @override
  _ResultCardState createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {

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
    return Center(
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        elevation: 0,
        child: Container(
          color: Colors.white,
          width: width*0.7,
          height: width*0.92,
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
                      ExtendedImage.network(
                        widget.musicSheet.picUrl!,
                        fit: BoxFit.fill,
                        alignment: Alignment.topLeft,
                        cache: true,
                        loadStateChanged: (ExtendedImageState state) {
                          switch (state.extendedImageLoadState) {
                            case LoadState.loading:
                              return Image.asset(
                                "assets/app.png",
                                fit: BoxFit.fill,
                              );
                              break;
                            case LoadState.failed:
                              return GestureDetector(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/app.png",
                                      fit: BoxFit.fill,
                                    ),
                                    Positioned(
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
                              break;
                            case LoadState.completed:
                              null;
                          }
                          return null;
                        },
                      ),
                      InkWell(
                        child: Container(
                          margin: const EdgeInsets.only(
                              right: 5,
                              bottom: 5
                          ),
                          child: Icon(
                              _playing?Icons.pause_circle_outline_rounded :Icons.play_circle_outline_rounded,
                              size: 88,
                              color: Colors.white60
                          ),
                        ),
                        onTap: () async {
                          ApiDio.getWord(widget.musicSheet.id.toString());
                          AudioPlayerUtil.playerHandle(model: widget.musicSheet);
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
                                    child: Text(widget.musicSheet.name+'-'+widget.musicSheet.author ,softWrap: true,
                                      overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 20),)
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

      ),
    );
  }
}
