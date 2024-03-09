import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabulary/tools/SQLTools.dart';
import 'package:vocabulary/tools/PermissionTools.dart';

import 'Page/HomePage.dart';
import 'package:flutter_splash_screen/flutter_splash_screen.dart';

import 'tools/ApiDio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> init() async {
    await readAndWriteImage();
    await ApiDio.getBan();
    await ApiDio.getNewMVID();
    await ApiDio.getNewMV();
    ApiDio.getSheet();
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
    Future.delayed(Duration(milliseconds: 1000), () {
      FlutterSplashScreen.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const HomePage(),
    );
  }
}
