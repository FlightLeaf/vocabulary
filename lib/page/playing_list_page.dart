import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../tools/audio_play_tools.dart';

class PlayingListPage extends StatefulWidget {
  const PlayingListPage({super.key});

  @override
  _PlayingListPageState createState() => _PlayingListPageState();
}

class _PlayingListPageState extends State<PlayingListPage> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text('当前播放列表'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: AudioPlayerUtil.list.length,
          itemBuilder: (context, index) {
            if (AudioPlayerUtil.state == PlayerState.playing) {
              if (AudioPlayerUtil.musicModel!.id ==
                  AudioPlayerUtil.list[index].id) {
                _isPlaying = true;
              } else {
                _isPlaying = false;
              }
            }
            return ListTile(
              isThreeLine: true,
              dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              title: Text(
                AudioPlayerUtil.list[index].name,
                style: TextStyle(
                    fontSize: 16,
                    color: _isPlaying ? Colors.blue : Colors.black54),
              ),
              subtitle: Text(
                AudioPlayerUtil.list[index].author,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: IconButton(
                onPressed: () {

                  if(AudioPlayerUtil.list[index] == AudioPlayerUtil.musicModel!){
                    AudioPlayerUtil.nextMusic();
                    AudioPlayerUtil.removeMusicModel(
                        model: AudioPlayerUtil.list[index]);
                    setState(() {});
                  }else{
                    AudioPlayerUtil.removeMusicModel(
                        model: AudioPlayerUtil.list[index]);
                    setState(() {});
                  }
                },
                icon: const Icon(
                  Icons.clear_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                AudioPlayerUtil.listPlayerHandle(
                    musicModels: AudioPlayerUtil.list,
                    musicModel: AudioPlayerUtil.list[index]);
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }
}
