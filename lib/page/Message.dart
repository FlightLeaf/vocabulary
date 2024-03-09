import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人中心'),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white, // 背景色设置为透明
          ),
          collapseMode: CollapseMode.parallax,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            onPressed: () {

            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        scrollDirection: Axis.vertical,// 使用ListView可以轻松实现滚动
        children: <Widget>[
          _buildProfileSection(),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildMusicEntrySection(),
          ),
        ],
      ),
    );
  }

  // 构建用户信息部分
  Widget _buildProfileSection() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('欢迎， 用户名', style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text('个性签名', style: TextStyle(fontSize: 16, color: Colors.grey))
        ],
      ),
    );
  }

  // 构建喜欢的音乐入口部分
  Widget _buildMusicEntrySection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.grey.shade200,
      ),
      padding: EdgeInsets.all(26),
      alignment: Alignment.center,
      margin: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child:_buildButton('我喜欢', Icons.favorite_sharp,Colors.red, () {

          }),),
          Expanded(child: _buildButton('本地音乐', Icons.folder_rounded,Colors.orange, () {

          }),),
          Expanded(child: _buildButton('播放记录', Icons.history_rounded, Colors.blueAccent,() {

          }),),
        ],
      ),
    );
  }

  // 辅助函数，用于创建按钮
  Widget _buildButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 24, color: color),
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12))
      ],
    );
  }
}
