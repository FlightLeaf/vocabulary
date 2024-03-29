import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vocabulary/deBug/deBug_list.dart';
import 'package:vocabulary/tools/audio_play_tools.dart';
import 'package:vocabulary/tools/login_state_tools.dart';
import 'package:vocabulary/tools/sharedPreferences_tools.dart';
import 'package:vocabulary/tools/sqlite_tools.dart';
import 'package:vocabulary/tools/permission_tools.dart';

import 'Page/home_page.dart';
import 'package:flutter_splash_screen/flutter_splash_screen.dart';

import 'tools/get_source_tools.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataUtils.init();
  if(DataUtils.hasKey('code')){
    DataUtils.remove('code');
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> init() async {
    await SqlTools.readAndWriteImage();
    await ApiDio.getNewMvId();
    await ApiDio.getNewMV();
    await ApiDio.getRandomMusic(2);
    hideScreen();
    ApiDio.getSheet();
    ApiDio.getHistory();
    ApiDio.getLove();
    ApiDio.getDownload();
    ApiDio.getMvHistory();
    AudioPlayerUtil.listPlayerHandle(musicModels: ApiDio.startList);
    DeBugMessage.addMistake('这是一个错误信息示例');
    LoginState.init();
  }

  @override
  void initState() {

    PermissionUtils.requestAllPermission();
    init();
    super.initState();
  }

  ///hide your splash screen
  Future<void> hideScreen() async {
    Future.delayed(Duration(microseconds: 88), () {
      FlutterSplashScreen.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'Flutter Music',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            secondary: Colors.blue,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          fontFamily: '黑体',
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.blue,
        ),
        home: HomePage(),
      ),
    );

  }
}
