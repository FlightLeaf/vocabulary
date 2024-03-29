/// Created by RongCheng on 2022/1/20.

import 'dart:ui';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:vocabulary/Page/search_result_page.dart';
import 'package:vocabulary/model/mv.dart';
import 'package:vocabulary/widget/video_player_bottom.dart';
import 'package:vocabulary/widget/video_player_center.dart';
import 'package:vocabulary/widget/video_player_gestures.dart';
import 'package:vocabulary/widget/video_player_top.dart';

import '../model/TempOther.dart';
import '../tools/get_source_tools.dart';
import '../tools/videos_play_tools.dart';

class VideoPlayerPage extends StatefulWidget {
  VideoPlayerPage({Key? key, required this.mvModel, required this.url})
      : super(key: key);

  final MvModel mvModel;
  final String url;

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  // 是否全屏
  bool get _isFullScreen =>
      MediaQuery.of(context).orientation == Orientation.landscape;
  Size get _window => MediaQueryData.fromView(window).size;
  double get _width => _isFullScreen ? _window.width : _window.width;
  double get _height => _isFullScreen ? _window.height : _window.width * 9 / 16;
  Widget? _playerUI;
  VideoPlayerTop? _top;
  VideoPlayerBottom? _bottom;
  LockIcon? _lockIcon; // 控制是否沉浸式的widget
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ApiDio.getMvComment(widget.mvModel.id.toString());
    VideoPlayerUtils.playerHandle(widget.url, autoPlay: true);
    VideoPlayerUtils.initializedListener(
        key: this,
        listener: (initialize, widget) {
          if (initialize) {
            _top ??= VideoPlayerTop(
              title: this.widget.mvModel.name +
                  ' - ' +
                  this.widget.mvModel.artistName,
            );
            _lockIcon ??= LockIcon(
              lockCallback: () {
                _top!.opacityCallback(!TempValue.isLocked);
                _bottom!.opacityCallback(!TempValue.isLocked);
              },
            );
            _bottom ??= VideoPlayerBottom(
              mvModel: this.widget.mvModel,
            );
            _playerUI = widget;
            if (!mounted) return;
            setState(() {});
          }
        });
    VideoPlayerUtils.positionListener(
        key: this,
        listener: (state) {
          setState(() {});
        });
  }

  String formatLikeCount(int count) {
    if (count < 1000) {
      // 如果小于1000，直接返回数字
      return count.toString();
    } else if (count < 10000) {
      // 如果小于10000，转换为k格式
      double kCount = count / 1000;
      return kCount.toStringAsFixed(1) + 'k';
    } else {
      // 如果大于等于10000，转换为w格式
      double wCount = count / 10000;
      return wCount.toStringAsFixed(1) + 'w';
    }
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
      backgroundColor: _isFullScreen ? Colors.black : Colors.white,
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: Colors.white70,
              title: Text(
                '${widget.mvModel.name} - ${widget.mvModel.artistName}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
      body: PopScope(
        onPopInvoked: (t) {
          VideoPlayerUtils.setPortrait();
        },
        child: _isFullScreen
            ? safeAreaPlayerUI()
            : Container(
                margin: EdgeInsets.only(
                  top: _isFullScreen ? 0 : 5,
                  bottom: _isFullScreen ? 0 : 5,
                  left: _isFullScreen ? 0 : 2,
                  right: _isFullScreen ? 0 : 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    safeAreaPlayerUI(),
                    const SizedBox(
                      height: 10,
                    ),
                    ApiDio.mvCommentList.isEmpty
                        ? Text('  相关音乐推荐：',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))
                        : Text('  热门评论：',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 2,
                    ),
                    Expanded(
                      child: ApiDio.mvCommentList.isEmpty
                          ? SearchResultPage(
                              searchWord: widget.mvModel.name,
                              isVideo: true,
                            )
                          : Container(
                              padding: const EdgeInsets.all(10),
                              child: ListView.builder(
                                itemCount: ApiDio.mvCommentList.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    isThreeLine: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 2),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      //child: Image.network(ApiDio.commentList[index].user.avatarUrl.toString()),
                                      child: ExtendedImage.network(
                                        ApiDio
                                            .mvCommentList[index].user.avatarUrl
                                            .toString(),
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topLeft,
                                        cache: true,
                                        loadStateChanged:
                                            (ExtendedImageState state) {
                                          switch (
                                              state.extendedImageLoadState) {
                                            case LoadState.loading:
                                              return Image.asset(
                                                "assets/app.png",
                                                fit: BoxFit.fill,
                                              );
                                            case LoadState.failed:
                                              return GestureDetector(
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: <Widget>[
                                                    Image.asset(
                                                      "assets/app.png",
                                                      fit: BoxFit.fill,
                                                    ),
                                                    const Positioned(
                                                      bottom: 0.0,
                                                      left: 0.0,
                                                      right: 0.0,
                                                      child: Text(
                                                        "load image failed, click to reload",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                onTap: () {
                                                  state.reLoadImage();
                                                },
                                              );
                                            case LoadState.completed:
                                              null;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    title: Text(
                                      '${ApiDio.mvCommentList[index].user.nickname}   ${ApiDio.mvCommentList[index].timeStr}',
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black),
                                    ),
                                    subtitle: Column(
                                      // 使用Column来包含文本和点赞量
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            ApiDio.mvCommentList[index].content,
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        Row(
                                          // 添加点赞量
                                          children: <Widget>[
                                            const Icon(Icons.favorite_rounded,
                                                size: 16, color: Colors.red),
                                            Text(
                                                ' ${formatLikeCount(ApiDio.mvCommentList[index].likedCount)}', // 假设likeCount是点赞数量
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey))
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      setState(() {});
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget safeAreaPlayerUI() {
    return SafeArea(
      // 全屏的安全区域
      top: !_isFullScreen,
      bottom: !_isFullScreen,
      left: !_isFullScreen,
      right: !_isFullScreen,
      child: SizedBox(
          height: _height,
          width: _width,
          child: _playerUI != null
              ? VideoPlayerGestures(
                  appearCallback: (appear) {
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
                )
              : Container(
                  alignment: Alignment.center,
                  color: Colors.black26,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                )),
    );
  }
}
