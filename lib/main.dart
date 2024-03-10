import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vocabulary/tools/DataTools.dart';
import 'package:vocabulary/tools/SQLTools.dart';
import 'package:vocabulary/tools/PermissionTools.dart';

import 'Page/HomePage.dart';
import 'package:flutter_splash_screen/flutter_splash_screen.dart';

import 'tools/ApiDio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataUtils.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> init() async {
    await SqlTools.readAndWriteImage();
    await ApiDio.getNewMVID();
    await ApiDio.getNewMV();
    ApiDio.getSheet();
    ApiDio.getHistory();
    ApiDio.getLove();
    ApiDio.getDownload();
    hideScreen();
  }

  @override
  void initState() {
    PermissionUtils.requestAllPermission();
    init();
    super.initState();
  }

  ///hide your splash screen
  Future<void> hideScreen() async {
    Future.delayed(Duration(microseconds: 500), () {
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
