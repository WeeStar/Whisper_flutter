import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/service/data/his_data_service.dart';
import 'package:whisper/service/http/api_service.dart';
import 'package:whisper/service/play/player_service.dart';
import 'package:whisper/view/common_view/dialog_view.dart';
import 'package:whisper/view/music_view/music_search_item.dart';
import 'package:whisper/view/search_view/search_app_bar.dart';
import 'package:whisper/view/player_view/player_view.dart';

class SearchView extends StatefulWidget {
  @override
  State<SearchView> createState() => new _SearchViewState();
}

class _SearchViewState extends State<SearchView> with TickerProviderStateMixin {
  //初始化构造searchbar
  AppBarSearch _searchBar;
  //分页列表
  EasyRefreshController _controller;

  //搜索历史
  List<String> _searchHis;

  //搜索结果
  int _page = 1;
  int _pageSize = 30;
  MusicSource _source;
  String _keyWord;
  List<MusicModel> _searchRes = new List<MusicModel>();
  bool _isInSearch = false;

  _SearchViewState() {
    //初始化搜索栏
    _searchBar = new AppBarSearch(
        provider: this,
        setState: setState,
        hintText: "搜索歌曲名 专辑名 歌手",
        onSubmitted: (text, source) {
          //执行搜索
          _search(text, source);
        },
        onTabChanged: (source) {
          //执行切换tab
          _search(_keyWord, source);
        },
        onCleared: () {
          //清空跳出搜索
          setState(() {
            _searchHis = HisDataService.searchHis;
            _isInSearch = false;
          });
        });

    //初始化搜索历史
    _searchHis = HisDataService.searchHis;
    _controller = EasyRefreshController();
  }

  @override
  void initState() {
    super.initState();
    YYDialog.init(context);
  }

  //搜索
  void _search(String keyWord, MusicSource source) {
    //重置搜索条件及结果
    _source = source;
    _keyWord = keyWord;
    _page = 1;

    //在搜索内
    setState(() {
      _searchRes = new List<MusicModel>();
      _isInSearch = true;
    });

    //插入记录
    HisDataService.addHis(keyWord);

    //执行搜索
    ApiService.searchMusic(_source, _keyWord, _page, _pageSize).then((value) {
      _page++;
      setState(() {
        _searchRes = value;
      });
    }).catchError((error) {});
  }

  Widget _buildList() {
    return EasyRefresh.custom(
      enableControlFinishLoad: true,
      controller: _controller,
      onLoad: () async {
        //向后获取推荐歌单数据
        await ApiService.searchMusic(_source, _keyWord, _page, _pageSize)
            .then((musicList) {
          //根据结果修改是否存在更多标志
          _controller.finishLoad(
              noMore: musicList.length == 0 ||
                  musicList.length < _pageSize ||
                  _searchRes
                      .any((element) => element.id == musicList.first.id));

          //为空 或 存在重复歌单 跳出
          if (musicList.length == 0 ||
              _searchRes.any((element) => element.id == musicList.first.id))
            return;

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
              return InkWell(
                child: MusicSearchItemView(_searchRes[index]),
                onTap: () {
                  PlayerService.play(music: _searchRes[index]);
                  //打开播放页面
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PlayerView();
                  }));
                },
              );
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "搜索历史",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).textTheme.bodyText1.color),
        ),
        InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_outline,
                size: 15,
                color: Theme.of(context).disabledColor,
              ),
              Text(
                "清空",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).disabledColor),
              )
            ],
          ),
          onTap: () {
            DialogView.showDialogView("是否清空搜索历史", "确定", "取消", () {
              if (_searchHis.length == 0) return;
              //清空搜索历史
              HisDataService.clearHis();
              setState(() {
                _searchHis = new List<String>();
              });
            }, () {
              return;
            });
          },
        )
      ],
    );
  }

  Widget _buildHis(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8,
      children: _searchHis.map((childNode) {
        return GestureDetector(
            onTap: () {
              //点击搜索历史
              _searchBar.setSearchText(childNode);
            }, //点击事件
            child: new ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                color: Theme.of(context).dividerTheme.color,
                child: Text(
                  childNode,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyText1.color,
                  ),
                ),
              ),
            ));
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: _searchBar.build(context),
        body: _isInSearch
            ? _buildList() //搜索结果
            //搜索历史
            : Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildHeader(context), //标头
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Theme.of(context).disabledColor,
                      height: 0.1,
                    ), //分割线
                    SizedBox(
                      height: 10,
                    ),
                    if (_searchHis.length == 0)
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "暂无历史数据",
                          style: TextStyle(
                              color: Theme.of(context).disabledColor,
                              fontSize: 12),
                        ),
                      )
                    else
                      // Text("youlishi")
                      _buildHis(context) //历史
                  ],
                ),
              ));
  }
}
