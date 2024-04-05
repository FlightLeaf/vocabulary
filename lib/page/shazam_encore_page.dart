import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:vocabulary/widget/result_card.dart';

import '../model/music.dart';
import '../tools/get_source_tools.dart';
import '../tools/audio_play_tools.dart';
import '../tools/permission_tools.dart';

class IdentifyPage extends StatefulWidget {
  const IdentifyPage({super.key});

  @override
  _IdentifyPageState createState() => _IdentifyPageState();
}

class _IdentifyPageState extends State<IdentifyPage>
    with SingleTickerProviderStateMixin {
  late String path;
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
      const timeout = Duration(seconds: 2);
      Timer(
        timeout,
        () async {
          await record.stop();
          Dio dio = Dio();
          try {
            Response response =
                await dio.post('http://114.55.94.213:5000/forward',
                    data: FormData.fromMap({
                      'audio': await MultipartFile.fromFile(path.toString()),
                    }));
            String data = response.data;
            isRecording = false;
            dio.close();
            final RegExp pattern = RegExp(r'(\d+)');
            final RegExpMatch match =
                pattern.firstMatch(data.toString())!;
            final String extractedNumber = match.group(0)!;

            await ApiDio.getMusic(int.parse(extractedNumber)).then((value) {
              if (value.mp3Url != '') {
                musicModel = value;
                isRES = true;
                isRecording = false;
                setState(() {});
              }
            });
          } catch (e) {
            isRecording = false;
            setState(() {});
          }
        },
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Container(), flex: 1,),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Center(
                child: isRecording
                    ? const Text(
                        "正在识别……",
                        style:
                            TextStyle(fontSize: 22, color: Colors.blueAccent),
                      )
                    : const Text(
                        "点击开始识别",
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(26),
              child: isRecording
                  ? Center(
                      child: Image.asset('assets/10002.gif'),
                    )
                  : InkWell(
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
          !isRES
              ? Expanded(flex: 1, child: Container())
              : Expanded(
                  flex: 8,
                  child:
                      !isRES ? Container() : ResultCard(musicSheet: musicModel),
                ),
          Expanded(flex: 1, child: Container()),
        ],
      ),
    );
  }
}
