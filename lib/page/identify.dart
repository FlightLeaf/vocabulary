import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:vocabulary/widget/result_card.dart';

import '../model/music.dart';
import '../tools/api_dio_get_source_tools.dart';
import '../tools/audio_play_tools.dart';
import '../tools/permission_tools.dart';


class IdentifyPage extends StatefulWidget {
  const IdentifyPage({super.key});

  @override
  _IdentifyPageState createState() => _IdentifyPageState();
}

class _IdentifyPageState extends State<IdentifyPage>
    with SingleTickerProviderStateMixin {
  var path;
  final record = Record();
  bool isRecording = false;
  late MusicModel musicModel;
  bool isRES = false;

  @override
  void initState() {
    super.initState();

    AudioPlayerUtil.statusListener(
      key: this,
      listener: (sate) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> recordMusic() async {
    bool per = await PermissionUtils.requestStoragePermission();
    if (await record.hasPermission() && per == true) {
      isRecording = true;
      Directory? tempDir = await getExternalStorageDirectory();
      String? dirloc = tempDir?.path;
      var name = "temp";
      path = "${dirloc!}$name.wav";
      await record.start(
        path: path.toString(),
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 8000,
      );
      const timeout = Duration(seconds:5);
      Timer( timeout, () async {
        await record.stop();
        Dio dio = Dio();
        try {

          Response response = await dio.post('http://114.55.94.213:5000/forward',
              data: FormData.fromMap({
                'audio': await MultipartFile.fromFile(path.toString()),
              }));
          print('==========='+response.data.toString());
          Map<String, dynamic> data = response.data;
          print("录音完毕");
          isRecording = false;
          dio.close();
          print(data['label'].toString());
          final RegExp pattern = RegExp(r'(\d+)');
          final RegExpMatch match = pattern.firstMatch(data['label'].toString())!;
          final String extractedNumber = match.group(0)!;
          print('==========='+extractedNumber);
          await ApiDio.getMp3Model(extractedNumber.toString())
              .then((value) {
            if (value.mp3Url != '') {
              musicModel = value;
              isRES = true;
              isRecording = false;
              setState(() {
              });
            }
          });
        } catch (e) {
          isRecording = false;
          print('"失败！"Error: $e');
          setState(() {
          });
        }
      },);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_downward_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Center(
                child: isRecording
                    ? Text(
                  "正在识别……",
                  style: TextStyle(fontSize: 24, color: Colors.grey[600]),
                )
                    : Text(
                  "点击开始识别",
                  style: TextStyle(fontSize: 24, color: Colors.grey[600]),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: isRecording?Center(
                child: Image.asset('assets/10002.gif'),
              ):InkWell(
                onTap: () {
                  setState(() {
                    recordMusic();
                  });
                },
                child: Center(
                  child: Image.asset('assets/10001.gif'),
                ),
              ),
            ),
          ),
          Expanded(
            flex:8,
            child:!isRES?Container():ResultCard(musicSheet: musicModel),
          ),
          //Expanded(flex: 1, child: Container()),
        ],
      ),
    );
  }
}
