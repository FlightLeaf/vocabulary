import 'package:flutter/material.dart';
import 'package:vocabulary/tools/get_source_tools.dart';

import '../tools/sqlite_tools.dart';
import '../widget/mv_card.dart';

class SearchMvResultPage extends StatefulWidget {
  const SearchMvResultPage({super.key, this.searchWord = '海底', this.url = ''});
  final String searchWord;
  final String url;

  @override
  _SearchMvResultPageState createState() => _SearchMvResultPageState();
}

class _SearchMvResultPageState extends State<SearchMvResultPage> with SingleTickerProviderStateMixin{

  final TextEditingController _searchController = TextEditingController();
  bool opened = false;
  bool state = false;

  Future<void> init() async {
    await ApiDio.getSearchMvId(widget.searchWord);
    await ApiDio.getSearchMV();
    state = true;
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.searchWord,
            hintStyle: TextStyle(color: Colors.grey[400]), // 提示文本样式
            filled: true, // 设置为true，应用背景颜色
            fillColor: Colors.white, // 背景颜色
            contentPadding: const EdgeInsets.only(
                left: 20,
                top: 10,
                bottom: 10,
                right: 10
            ), // 内边距，增加输入文本与边框的距离
            border: OutlineInputBorder( // 边框样式
              borderRadius: BorderRadius.circular(10), // 圆角边框
            ),
            suffixIcon: IconButton(
              alignment: Alignment.centerLeft,
              icon: const Icon(Icons.search_sharp, color: Colors.black,), // 搜索图标颜色
              onPressed: () async {
                if(_searchController.text.isEmpty) return;
                SqlTools.inSearch(_searchController.text);
                await ApiDio.getSearchWord();
                setState(() {});
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SearchMvResultPage(
                    searchWord: _searchController.text == ''
                        ? widget.searchWord
                        : _searchController.text,),
                ),);
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        child: state?ListView.builder(
          itemCount: ApiDio.searchMvList.length,
          itemBuilder: (context, index) {
            return MvCard(mvSheet: ApiDio.searchMvList[index]);
          },
        ):const Center(
          child: Text('加载中...'),
        ),
        onRefresh: () async {
          await ApiDio.getSearchMvId(widget.searchWord);
          await ApiDio.getSearchMV();
          setState(() {

          });
        },
      ),
    );
  }
}
