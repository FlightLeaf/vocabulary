import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vocabulary/model/mv.dart';
import 'package:vocabulary/tools/get_source_tools.dart';

import 'package:vocabulary/tools/audio_play_tools.dart';
import 'package:vocabulary/tools/sqlite_tools.dart';
import '../page/video_player_page.dart';

class MvCard extends StatefulWidget {
  MvCard({Key? key, required this.mvSheet, this.isHistory = false}) : super(key: key);

  final MvModel mvSheet;

  final bool isHistory;

  @override
  _MvCardState createState() => _MvCardState();
}

class _MvCardState extends State<MvCard> {

  late String url;

  void getUrl(){
    List<String> resolutions = ['1080', '720', '480', '240'];
    for (String resolution in resolutions) {
      if (widget.mvSheet.brs.containsKey(resolution)) {
        if (resolution == '1080') {
          url = widget.mvSheet.brs['1080'].toString();
        } else if (resolution == '720') {
          url = widget.mvSheet.brs['720'].toString();
        } else if (resolution == '480') {
          url = widget.mvSheet.brs['480'].toString();
        } else if (resolution == '240') {
          url = widget.mvSheet.brs['240'].toString();
        }
        break;
      }else{
        continue;
      }
    }
    setState(() {

    });
  }

  String historyUrl = '';

  @override
  void initState() {
    getUrl();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      elevation: 0,
      child: Container(
        color: Colors.white,
        width: width * 0.88,
        height: width * 0.618,
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
                  await ApiDio.getMvURL(widget.mvSheet.id.toString())
                      .then((value) {
                        print('------------------------------------------------$value');
                    historyUrl = value;
                  });
                  if (AudioPlayerUtil.state == PlayerState.playing) {
                    AudioPlayerUtil.listPlayerHandle(
                        musicModels: AudioPlayerUtil.list);
                  }
                  SqlTools.inMvHistory(widget.mvSheet);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(
                      mvModel: widget.mvSheet,
                      url: historyUrl,
                    ),
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
                              flex: 10,
                              child: Container(
                                alignment: Alignment.topCenter,
                                child: Center(
                                  child: Text(
                                    '${widget.mvSheet.name} - ${widget.mvSheet.artistName}',
                                    style: const TextStyle(fontSize: 15),
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
