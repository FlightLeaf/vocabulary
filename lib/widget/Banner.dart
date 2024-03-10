import 'package:flutter/material.dart';

import 'package:card_swiper/card_swiper.dart';

import '../tools/ApiDio.dart';


class BannerPage extends StatefulWidget {
  const BannerPage({super.key});

  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {

  Future<void> init() async{
    await ApiDio.getBan();
    setState(() {
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ApiDio.ban.isEmpty? Container() :Swiper(
      itemBuilder: (BuildContext context,int index){
        return Image.network(ApiDio.ban[index],fit: BoxFit.fill,);
      },
      itemCount: 8,
      loop: true,
      autoplay: true,
    );
  }
}