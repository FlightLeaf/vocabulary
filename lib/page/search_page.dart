import 'package:flutter/material.dart';
import 'package:vocabulary/tools/sqlite_tools.dart';

import '../tools/get_source_tools.dart';
import 'search_result_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchResults = [];
  bool noHistory = true;

  @override
  void initState() {
    ApiDio.getSearchWord();
    setState(() {});
    super.initState();
    _searchController.addListener(() {
      if (mounted) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: TextField(
          onChanged: (value) async {
            await ApiDio.getSearchSuggest(value);
            if(ApiDio.historySuggest.isNotEmpty){
              noHistory = false;
            }else{
              noHistory = true;
            }
            setState(() {});
          },
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '输入搜索词...',
            hintStyle: TextStyle(color: Colors.grey[400]), // 提示文本样式
            filled: true,
            fillColor: Colors.white, // 背景颜色
            contentPadding: const EdgeInsets.only(
                left: 10, top: 10, bottom: 10, right: 10), // 内边距，增加输入文本与边框的距离
            border: OutlineInputBorder(
              // 边框样式
              borderRadius: BorderRadius.circular(10), // 圆角边框
            ),
            suffixIcon: IconButton(
              alignment: Alignment.centerLeft,
              icon: const Icon(
                Icons.search_sharp,
                color: Colors.black,
              ), // 搜索图标颜色
              onPressed: () async {
                if (_searchController.text.isEmpty) return;
                SqlTools.inSearch(_searchController.text);
                await ApiDio.getSearchWord();
                setState(() {});
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SearchResultPage(
                    searchWord: _searchController.text,
                  ),
                ));
              },
            ),
          ),
        ),
      ),
      body: noHistory?RefreshIndicator(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(left: 18, top: 10),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_filled_rounded,
                    color: Colors.blueAccent,
                  ),
                  const Text(
                    '搜索历史',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    alignment: Alignment.center,
                    onPressed: () async {
                      await SqlTools.deSearch();
                      await ApiDio.getSearchWord();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.blue,
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, top: 8),
              color: Colors.white,
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: ApiDio.searchList.isEmpty
                      ? []
                      : ApiDio.searchList
                          .map(
                            (song) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: InkWell(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    color: Colors.grey.shade200,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    child: Text(
                                      song,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  SqlTools.inSearch(song);
                                  await ApiDio.getSearchWord();
                                  setState(() {});
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => SearchResultPage(
                                      searchWord: song,
                                    ),
                                  ));
                                },
                              ),
                            ),
                          )
                          .toList(),
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
                  margin: const EdgeInsets.only(left: 18),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.redAccent,
                      ),
                      const Text(
                        '今日热搜',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          ApiDio.getHotList();
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )),
            ),
            Expanded(
              flex: 40,
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  itemCount: ApiDio.hotModelList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      dense: true,
                      title: Text(
                        '${index + 1}  ${ApiDio.hotModelList[index].searchWord}',
                        style: TextStyle(fontSize: 16),
                      ), // 显示序号和搜索词
                      trailing: ApiDio.hotModelList[index].iconUrl != null &&
                              index != 2
                          ? Image.network(
                              width: width * 0.04,
                              ApiDio.hotModelList[index].iconUrl!)
                          : const Text(''),
                      onTap: () async {
                        SqlTools.inSearch(
                            ApiDio.hotModelList[index].searchWord);
                        await ApiDio.getSearchWord();
                        setState(() {});
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SearchResultPage(
                            searchWord: ApiDio.hotModelList[index].searchWord,
                          ),
                        ));
                      },
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(),
            )
          ],
        ),
        onRefresh: () async {
          ApiDio.getHotList();
          await ApiDio.getSearchWord();
          setState(() {});
        },
      ):Container(
        height: 280,
        child: ListView.builder(
          itemCount: ApiDio.historySuggest.length,
          itemBuilder: (context, index) {
            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 4),
              title: Text(
                ApiDio.historySuggest[index],
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () async {
                SqlTools.inSearch(ApiDio.historySuggest[index]);
                await ApiDio.getSearchWord();
                setState(() {});
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SearchResultPage(
                    searchWord: ApiDio.historySuggest[index],
                  ),
                ));
              },
            );
          },
        ),
      ),
    );
  }
}
