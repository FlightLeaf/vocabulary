/// Created by RongCheng on 2022/3/3.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/music.dart';
import '../tools/audio_play_tools.dart';

class AudioSlider extends StatefulWidget {
  AudioSlider({Key? key}) : super(key: key);

  @override
  State<AudioSlider> createState() => _AudioSliderState();
}

class _AudioSliderState extends State<AudioSlider> {
  late MusicModel musicModel = AudioPlayerUtil.musicModel!;
  double _value = 0.0;
  int _total = 0; // 假设总时间为
  String _totalDuration = "00:00";
  String _currentDuration = "00:00";
  ui.Image? _customImage; // 自定义thumbShape

  @override
  void initState() {
    super.initState();
    AudioPlayerUtil.statusListener(key: this, listener: (sate){
      if(mounted){
        setState(() {
          musicModel = AudioPlayerUtil.musicModel!;
        });
      }
    });
    AudioPlayerUtil.getAudioDuration(url: musicModel.mp3Url).then((duration){
      if(duration!.inMilliseconds > 0){
        _total = duration.inSeconds;
        if(mounted){
          setState(() {
            _totalDuration = _updateDuration(duration.inSeconds);
            if(AudioPlayerUtil.musicModel != null){
              if(AudioPlayerUtil.musicModel!.mp3Url == musicModel.mp3Url){
                _value = AudioPlayerUtil.position.inSeconds / _total;
              }
            }
          });
        }
      }
      setState(() {});
    });
    loadImage().then((image) {
      _customImage = image;
      if(!mounted) return;
      setState(() {});
    });
    // 播放进度回调
    AudioPlayerUtil.positionListener(key: this, listener: (position){
      if(_total == 0) return;
      if(AudioPlayerUtil.musicModel == null) return;
      if(AudioPlayerUtil.musicModel!.mp3Url != musicModel.mp3Url) return;
      if(mounted){
        setState(() {
          _value = position / _total;
          _currentDuration = _updateDuration(position);
        });
      }
    });
  }

  Future<ui.Image> loadImage() async {
    ByteData data = await rootBundle.load("assets/images/image.png");
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                inactiveTrackColor: Colors.grey,
                activeTrackColor: Colors.yellow,
                thumbShape: SliderThumbImage(image: _customImage),
                trackShape: const CustomTrackShape(),
              ),
              child: Slider(
                value: _value,
                onChangeStart: (double value){
                  setState(() {
                    _value = value;
                  });
                },
                onChangeEnd: (double value){ // 拖拽跳转
                  setState(() {
                    _value = value;
                  });
                  AudioPlayerUtil.seekTo(position: Duration(seconds: (_value*_total).truncate()), model: musicModel);
                },
                onChanged: (double value) {
                  setState(() {
                    _value = value;
                  });
                },),
            ),
          ),
          Row(
            children: [
              Text(_currentDuration,style: const TextStyle(fontSize: 14,color: Colors.black87),),
              const Spacer(),
              Text(_totalDuration,style: const TextStyle(fontSize: 14,color: Colors.black87),)
            ],
          )
        ],
      ),
    );
  }

  String _updateDuration(int second){
    int min = second ~/ 60;
    int sec = second % 60;
    String minString = min < 10 ? "0$min" : min.toString();
    String secString = sec < 10 ? "0$sec" : sec.toString();
    return minString+":"+secString;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    AudioPlayerUtil.removePositionListener(this);
    super.dispose();
  }
}

class SliderThumbImage extends SliderComponentShape{
  const SliderThumbImage({Key? key,this.image});
  final ui.Image? image;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(0, 0);
  }
  @override
  void paint(PaintingContext context, Offset center, {
    required Animation<double> activationAnimation, required Animation<double> enableAnimation,
    required bool isDiscrete, required TextPainter labelPainter, required RenderBox parentBox,
    required SliderThemeData sliderTheme, required TextDirection textDirection, required double value,
    required double textScaleFactor, required Size sizeWithOverflow}) {

    final canvas = context.canvas;
    final imageWidth = image?.width ?? 10;
    final imageHeight = image?.height ?? 10;
    Offset imageOffset = Offset(
      center.dx - imageWidth *0.5,
      center.dy - imageHeight *0.5-2,
    );
    if (image != null) {
      canvas.drawImage(image!, imageOffset, Paint());
    }
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  const CustomTrackShape();
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,}) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackWidth = parentBox.size.width;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}