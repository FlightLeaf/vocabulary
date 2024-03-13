import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vocabulary/model/mv.dart';

import 'package:vocabulary/tools/audio_play_tools.dart';
import '../videos/video_player_page.dart';


class MvCard extends StatefulWidget {
  const MvCard({Key? key,required this.mvSheet}) : super(key: key);

  final MvModel mvSheet;

  @override
  _MvCardState createState() => _MvCardState();
}

class _MvCardState extends State<MvCard> {

  @override
  void initState() {
    super.initState();
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
        width: width*0.88,
        height: width*0.618,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
              child: InkWell(
                onTap: () async {
                  if(AudioPlayerUtil.state == PlayerState.playing){
                    AudioPlayerUtil.listPlayerHandle(musicModels: AudioPlayerUtil.list);
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(mvModel: widget.mvSheet,url: widget.mvSheet.brs['720'].toString(),),
                  ));
                },
                child: Column(
                  children: [
                    Expanded(
                      flex: 13,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        child: Image.network(
                          widget.mvSheet.cover,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Expanded(
                              flex:10,
                              child: Container(
                                  alignment: Alignment.topCenter,
                                  child: Center(
                                    child:Text(
                                      widget.mvSheet.name+' - '+widget.mvSheet.artistName,
                                      style: TextStyle(fontSize: 15),
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}