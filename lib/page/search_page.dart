import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vocabulary/page/identify.dart';
import 'package:vocabulary/tools/sqlite_tools.dart';

import '../tools/api_dio_get_source_tools.dart';
import 'search_result_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  final TextEditingController _searchController = TextEditingController();
  List<String> searchResults = [];

  @override
  void initState() {
    ApiDio.getSearchWord();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    final width =size.width;
    final height =size.height;
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            child: Image.asset('assets/mac.png',width: width*0.075,),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => IdentifyPage(),
              ));
            },
          ),
          SizedBox(width: 18,)
        ],
        surfaceTintColor: Colors.white,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '输入搜索词...',
            hintStyle: TextStyle(color: Colors.grey[400]), // 提示文本样式
            filled: true,
            fillColor: Colors.white, // 背景颜色
            contentPadding: EdgeInsets.only(
                left: 20,
                top: 10,
                bottom: 10,
                right: 10
            ), // 内边距，增加输入文本与边框的距离
            border: OutlineInputBorder( // 边框样式
              borderRadius: BorderRadius.circular(30), // 圆角边框
            ),
            suffixIcon: IconButton(
              alignment: Alignment.centerLeft,
              icon: Icon(Icons.search_sharp, color: Colors.black,), // 搜索图标颜色
              onPressed: () async {
                if(_searchController.text.isEmpty) return;
                await SqlTools.inSearch(_searchController.text);
                await ApiDio.getSearchWord();
                setState(() {});
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SearchResultPage(searchWord: _searchController.text,),
                ));
              },
            ),
          ),
        ),

      ),
      body: RefreshIndicator(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              margin: EdgeInsets.only(left: 18, top: 10),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.access_time_filled_rounded,color: Colors.blueAccent,),
                  Text('搜索历史', style: TextStyle(fontSize: 18,color: Colors.blue ,fontWeight: FontWeight.bold),),
                  IconButton(
                    alignment: Alignment.center,
                    onPressed: () async {
                      await SqlTools.deSearch();
                      await ApiDio.getSearchWord();
                      setState(() {});
                    },
                    icon: Icon(Icons.delete, size: 18, color: Colors.blue,),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 8, top: 8),
              color: Colors.white,
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: ApiDio.searchList.isEmpty ? [] : ApiDio.searchList.map((song) =>
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: InkWell(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              color: Colors.grey.shade200,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Text(song, style: TextStyle(fontSize: 15),),
                            ),
                          ),
                          onTap: () async {
                            await SqlTools.inSearch(song);
                            await ApiDio.getSearchWord();
                            setState(() {});
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SearchResultPage(searchWord: song,),
                            ));
                          },
                        ),
                      ),
                  ).toList(),
                ),
              ),
            ),
            Divider(
              indent: 15,
              endIndent: 15,
              color: Colors.grey.shade200,
            ),
            Expanded(
              flex: 5,
              child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(
                      left: 18
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,color: Colors.redAccent,),
                      Text('热歌榜', style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),),
                      IconButton(
                        onPressed: (){
                          final random = Random();
                          int randomNumber = random.nextInt(4) + 1;
                          ApiDio.getHotList(id: randomNumber.toString());
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )
              ),
            ),
            Expanded(
              flex: 40,
              child:Container(
                color: Colors.white,
                child: ListView.builder(
                  itemCount: ApiDio.hotModelList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      dense: true,
                      title: Text('${index + 1}  ${ApiDio.hotModelList[index].searchWord}',style: TextStyle(fontSize: 16),), // 显示序号和搜索词
                      onTap: () async {
                        await SqlTools.inSearch(ApiDio.hotModelList[index].searchWord);
                        await ApiDio.getSearchWord();
                        setState(() {    });
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SearchResultPage(searchWord: ApiDio.hotModelList[index].searchWord,),
                        ));
                      },
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child:Container(),
            ),
          ],
        ),
        onRefresh: () async {
          // 创建一个随机数生成器
          final random = Random();
          // 生成1到4之间的随机整数
          int randomNumber = random.nextInt(4) + 1;
          ApiDio.getHotList(id:randomNumber.toString());
          await ApiDio.getSearchWord();
          setState(() {});
        },
      ),
    );
  }
}
