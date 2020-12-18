import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/service/http/api_service.dart';
import 'package:whisper/view/common_view/common_view.dart';
import 'package:whisper/view/music_view/music_search_item.dart';

class SearchResView extends StatefulWidget {
  final MusicSource source;
  final String keyWord;

  SearchResView({this.source, this.keyWord});

  @override
  State<SearchResView> createState() => new _SearchResViewState();
}

class _SearchResViewState extends State<SearchResView>
    with TickerProviderStateMixin {
  //分页列表
  EasyRefreshController _controller;

  //搜索结果
  int _page = 1;
  int _pageSize = 30;
  bool _isLoading = true;
  List<MusicModel> _searchRes = new List<MusicModel>();

  _SearchResViewState() {
    _controller = EasyRefreshController();
  }

  @override
  void initState() {
    super.initState();
    YYDialog.init(context);

    //请求数据
    ApiService.searchMusic(widget.source, widget.keyWord, _page, _pageSize)
        .then((musicList) {
      //根据结果修改是否存在更多标志
      _controller.finishRefresh(
          noMore: musicList.length == 0 ||
              musicList.length < _pageSize ||
              _searchRes.any((element) => element.id == musicList.first.id));

      //追加列表数据
      _page++;
      setState(() {
        _isLoading = false;
        _searchRes.addAll(musicList);
      });
    }).catchError((error) {
      _controller.finishLoad(noMore: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        //等待图
        ? CommonView.buildLoadingView(context)
        //列表
        : EasyRefresh.custom(
            enableControlFinishLoad: true,
            controller: _controller,
            onLoad: () async {
              //向后获取推荐歌单数据
              await ApiService.searchMusic(
                      widget.source, widget.keyWord, _page, _pageSize)
                  .then((musicList) {
                //根据结果修改是否存在更多标志
                _controller.finishLoad(
                    noMore: musicList.length == 0 ||
                        musicList.length < _pageSize ||
                        _searchRes.any(
                            (element) => element.id == musicList.first.id));

                //为空 或 存在重复歌单 跳出
                if (musicList.length == 0 ||
                    _searchRes.any(
                        (element) => element.id == musicList.first.id)) return;

                //追加列表数据
                _page++;
                setState(() {
                  _searchRes.addAll(musicList);
                });
              }).catchError((error) {
                _controller.finishLoad(noMore: true);
              });
            },
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return MusicSearchItemView(_searchRes[index]);
                  },
                  childCount: _searchRes.length,
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
          );
  }
}
