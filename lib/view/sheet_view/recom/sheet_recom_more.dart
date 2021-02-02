import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'package:flutter/material.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/service/http/api_service.dart';
import 'package:whisper/view/sheet_view/item/sheet_list_item.dart';

class SheetRecomMoreView extends StatefulWidget {
  final MusicSource _source;
  final List<SheetModel> _sheetList;
  SheetRecomMoreView(this._source, this._sheetList);

  @override
  State<SheetRecomMoreView> createState() =>
      new _SheetRecomMoreViewState(_sheetList);
}

class _SheetRecomMoreViewState extends State<SheetRecomMoreView>
    with TickerProviderStateMixin {
  EasyRefreshController _controller;
  List<SheetModel> _sheetList;

  int _pageIndex = 2;
  final int _pageSize = 30;

  _SheetRecomMoreViewState(this._sheetList);

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(title: Text("${widget._source.desc} 推荐歌单"))),
      body: EasyRefresh.custom(
        enableControlFinishLoad: true,
        controller: _controller,
        onLoad: () async {
          //向后获取推荐歌单数据
          await ApiService.getRecomSheetSingle(
                  widget._source, _pageIndex, _pageSize)
              .then((recomList) {
            //根据结果修改是否存在更多标志
            _controller.finishLoad(
                noMore: recomList.sheets.length == 0 ||
                    recomList.sheets.length < _pageSize ||
                    _sheetList.any(
                        (element) => element.id == recomList.sheets.first.id));

            //为空 或 存在重复歌单 跳出
            if (_sheetList.length == 0 ||
                _sheetList
                    .any((element) => element.id == recomList.sheets.first.id))
              return;

            //追加列表数据
            setState(() {
              _sheetList.addAll(recomList.sheets);
            });
            _pageIndex++;
          }).catchError((error) {
            _controller.finishLoad(noMore: true);
          });
        },
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return SheetListItemView(_sheetList[index], 1);
              },
              childCount: _sheetList.length,
            ),
          ),
        ],
        footer: ClassicalFooter(
            extent: 80,
            triggerDistance: 240,
            completeDuration: Duration(seconds: 2),
            loadText: "正在加载,请稍后...",
            loadingText: "正在加载,请稍后...",
            loadedText: "正在加载,请稍后...",
            noMoreText: "没有更多了",
            infoText: "音乐无界  万象森罗",
            textColor: Theme.of(context).textTheme.bodyText1.color,
            infoColor: Theme.of(context).primaryColor),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
