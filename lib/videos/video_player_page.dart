/// Created by RongCheng on 2022/1/20.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vocabulary/model/mv.dart';
import 'package:vocabulary/videos/video_player_bottom.dart';
import 'package:vocabulary/videos/video_player_center.dart';
import 'package:vocabulary/videos/video_player_gestures.dart';
import 'package:vocabulary/videos/video_player_top.dart';

import '../model/TempOther.dart';
import '../tools/videos_play_tools.dart';

class VideoPlayerPage extends StatefulWidget {
  VideoPlayerPage({Key? key, required this.mvModel, required this.url}) : super(key: key);

  final MvModel mvModel;
  final String url;

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  // 是否全屏
  bool get _isFullScreen => MediaQuery.of(context).orientation == Orientation.landscape;
  Size get _window => MediaQueryData.fromView(window).size;
  double get _width => _isFullScreen ? _window.width : _window.width;
  double get _height => _isFullScreen ? _window.height : _window.width*9/16;
  Widget? _playerUI;
  VideoPlayerTop? _top;
  VideoPlayerBottom? _bottom;
  LockIcon? _lockIcon; // 控制是否沉浸式的widget
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    VideoPlayerUtils.playerHandle(widget.url,autoPlay: true);
    VideoPlayerUtils.initializedListener(key: this, listener: (initialize,widget){
      print('+++++++++++++++++++++');
      if(initialize){
        _top ??= VideoPlayerTop(title: this.widget.mvModel.name+' - '+this.widget.mvModel.artistName,);
        _lockIcon ??= LockIcon(lockCallback: (){
          _top!.opacityCallback(!TempValue.isLocked);
          _bottom!.opacityCallback(!TempValue.isLocked);
        },);
        _bottom ??= VideoPlayerBottom(mvModel: this.widget.mvModel,);
        _playerUI = widget;
        if(!mounted) return;
        setState(() {});
      }
    });
    VideoPlayerUtils.positionListener(key: this, listener: (state){
      print(state);
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    VideoPlayerUtils.removeInitializedListener(this);
    VideoPlayerUtils.removePositionListener(this);
    VideoPlayerUtils.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isFullScreen ?Colors.black: Colors.white,
      appBar: _isFullScreen ?null: AppBar(
        backgroundColor: Colors.white70,
      ),
      body: PopScope(
        onPopInvoked: (t){
          VideoPlayerUtils.setPortrait();
        },
        child: _isFullScreen ? safeAreaPlayerUI() : Column(
          children: [
            safeAreaPlayerUI(),
            const SizedBox(height: 100,),
            Container(
              child: Column(
                children: [
                  Text(widget.mvModel.name),
                  SizedBox(height: 10,),
                  Text(widget.mvModel.artistName),
                ],
              ),
            )
          ],
        )
      ),
    );
  }

  Widget safeAreaPlayerUI(){
    return SafeArea( // 全屏的安全区域
      top: !_isFullScreen,
      bottom: !_isFullScreen,
      left: !_isFullScreen,
      right: !_isFullScreen,
      child: SizedBox(
        height: _height,
        width: _width,
        child: _playerUI != null ? VideoPlayerGestures(
          appearCallback: (appear){
            _top!.opacityCallback(appear);
            _lockIcon!.opacityCallback(appear);
            _bottom!.opacityCallback(appear);
            },
          children: [
            Container(
              color: Colors.black26,
              child: Center(
                child: _playerUI,
              ),
            ),
            _top!,
            _lockIcon!,
            _bottom!
          ],
        ) : Container(
          alignment: Alignment.center,
          color: Colors.black26,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
          ),
        )
      ),
    );
  }
}
