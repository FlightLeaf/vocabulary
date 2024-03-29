import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vocabulary/model/music.dart';
import 'package:vocabulary/tools/get_source_tools.dart';
import 'package:vocabulary/tools/audio_play_tools.dart';

import 'dart:convert';
import '../deBug/deBug_list.dart';
import '../model/search.dart';
import '../tools/sqlite_tools.dart';
import '../widget/mv_card.dart';

class DeBugPage extends StatefulWidget {
  const DeBugPage({super.key});
  @override
  _DeBugPageState createState() => _DeBugPageState();
}

class _DeBugPageState extends State<DeBugPage>
    with SingleTickerProviderStateMixin {
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
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text('DeBug'),
      ),
      //通过ListViewBuilder显示List<String> mistakes中的数据
      body: ListView.builder(
        itemCount: DeBugMessage.mistakes.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(10.0),
            width: double.infinity,
            child:Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(width: 1, color: Colors.grey),
              ),
              child:Container(
                margin: const EdgeInsets.all(10.0),
                alignment: Alignment.centerLeft,
                child: Text(
                    DeBugMessage.mistakes[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
