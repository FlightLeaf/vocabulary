import 'package:flutter/material.dart';
import 'package:vocabulary/tools/get_source_tools.dart';

import '../widget/mv_card.dart';

class MvResultPage extends StatefulWidget {
  const MvResultPage({super.key, this.searchWord = '海底', this.url = ''});
  final String searchWord;
  final String url;

  @override
  _MvResultPageState createState() => _MvResultPageState();
}

class _MvResultPageState extends State<MvResultPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool opened = false;
  bool state = false;

  Future<void> init() async {
    await ApiDio.getSearchMvId(widget.searchWord);
    await ApiDio.getSearchMV();
    state = true;
    setState(() {});
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ), // 返回箭头
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        child: state
            ? ListView.builder(
                itemCount: ApiDio.searchMvList.length,
                itemBuilder: (context, index) {
                  return MvCard(mvSheet: ApiDio.searchMvList[index]);
                },
              )
            : const Center(
                child: Text('加载中...'),
              ),
        onRefresh: () async {
          await ApiDio.getSearchMvId(widget.searchWord);
          await ApiDio.getSearchMV();
          setState(() {});
        },
      ),
    );
  }
}
