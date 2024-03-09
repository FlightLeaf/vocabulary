import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../tools/AudioPlayerTools.dart';

class playList extends StatefulWidget {
  playList({super.key});

  @override
  _playListState createState() => _playListState();
}

class _playListState extends State<playList> {

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    AudioPlayerUtil.positionListener(key: this, listener: (position){
      if(mounted){
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    AudioPlayerUtil.removePositionListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text('当前播放列表'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child:ListView.builder(
          itemCount: AudioPlayerUtil.list.length,
          itemBuilder: (context, index) {
            if(AudioPlayerUtil.musicModel == AudioPlayerUtil.list[index]) {
              _isPlaying = true;
            }else{
              _isPlaying = false;
            }
            return ListTile(
              isThreeLine: true,
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              title: Text(AudioPlayerUtil.list[index].name, style: TextStyle(fontSize: 16, color: _isPlaying?Colors.blue:Colors.black54),),
              subtitle: Text(AudioPlayerUtil.list[index].author, style: TextStyle(fontSize: 12),),
              trailing: IconButton(
                onPressed: (){
                  AudioPlayerUtil.removeMusicModel(model: AudioPlayerUtil.list[index]);
                  setState(() {});
                },
                icon:Icon(Icons.clear_outlined,size: 18,color: Colors.grey,),
              ),
              onTap: (){
                AudioPlayerUtil.listPlayerHandle(musicModels: AudioPlayerUtil.list, musicModel: AudioPlayerUtil.list[index]);
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }
}
