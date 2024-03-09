import 'package:flutter/material.dart';
import 'package:vocabulary/model/music.dart';

import '../tools/ApiDio.dart';
import '../tools/AudioPlayerTools.dart';

class CommentList extends StatefulWidget {
  CommentList({super.key, required this.musicModel});
  final MusicModel musicModel;
  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {

  late MusicModel musicModel;
  @override
  void initState() {
    musicModel = AudioPlayerUtil.musicModel!;
    init();
    super.initState();
  }

  void init() async{
    //await ApiDio.getComment(widget.musicModel.id.toString());
    setState(() {
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text('热门评论'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child:ListView.builder(
          itemCount: ApiDio.commentList.length,
          itemBuilder: (context, index) {
            return ListTile(
              isThreeLine: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(ApiDio.commentList[index].user.avatarUrl.toString()),
              ),
              title: Text(
                ApiDio.commentList[index].user.nickname +
                    '   ' +
                    ApiDio.commentList[index].timeStr.year.toString() +
                    '-' +
                    ApiDio.commentList[index].timeStr.month.toString() +
                    '-' +
                    ApiDio.commentList[index].timeStr.day.toString(),
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              subtitle: Column( // 使用Column来包含文本和点赞量
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(ApiDio.commentList[index].content, style: TextStyle(fontSize: 12)),
                  Row( // 添加点赞量
                    children: <Widget>[
                      Icon(Icons.favorite_rounded, size: 16, color: Colors.red),
                      Text(' ' + formatLikeCount(ApiDio.commentList[index].likedCount), // 假设likeCount是点赞数量
                          style: TextStyle(fontSize: 12, color: Colors.grey))
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
    );
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

}
