import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/service/data/config_data_service.dart';
import 'package:whisper/service/data/his_data_service.dart';
import 'package:whisper/service/data/my_sheets_data_service.dart';
import 'package:whisper/service/http/api_service.dart';
import 'package:whisper/view/common_view/dialog.dart';
import 'package:whisper/view/main_view/main_view_setting.dart';
import 'package:whisper/view/main_view/main_view_my.dart';
import 'package:whisper/view/main_view/main_view_recom.dart';
import 'package:whisper/view/main_view/nav_icon_view.dart';
import 'package:whisper/view/player_view/player_ring.dart';
import 'package:whisper/view/player_view/player_view.dart';
import 'package:whisper/view/search_view/search_view.dart';
import 'package:whisper/view/sheet_view/add/sheet_add_view.dart';
import 'package:whisper/view/sheet_view/info/sheet_info_view.dart';

//导航tab
class MainTab extends StatefulWidget {
  MainTab(this.recomSheets);
  final List<RecomModel> recomSheets;

  @override
  State<MainTab> createState() => new _IndexState();
}

class _IndexState extends State<MainTab> with TickerProviderStateMixin {
  int _currentIndex = 0; //选中index
  List<NavigationIconView> _navigationViews; //导航图标
  List<Widget> _pageList; //导航显示页面
  // StatefulWidget _currentPage; //当前页面

  @override
  void initState() {
    super.initState();

    //初始化导航图标
    _navigationViews = <NavigationIconView>[
      new NavigationIconView(
        icon: new Icon(Icons.track_changes),
        title: new Text("推荐"),
        vsync: this,
      ),
      new NavigationIconView(
        icon: new Icon(Icons.audiotrack),
        title: new Text("我的"),
        vsync: this,
      ),
      new NavigationIconView(
        icon: new Icon(Icons.person),
        title: new Text("设置"),
        vsync: this,
      ),
    ];

    for (NavigationIconView view in _navigationViews) {
      view.controller.addListener(_rebuild);
    }

    //页面列表
    _pageList = <Widget>[
      new MainViewRecom(widget.recomSheets), //推荐页面
      new MainViewMy(),
      new MainViewSetting(),
    ];
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    for (NavigationIconView view in _navigationViews) {
      view.controller.dispose();
    }
  }

  Widget _buildAppBar() {
    //标题
    var title = "";
    switch (_currentIndex) {
      case 0:
        title = "推荐歌单";
        break;
      case 1:
        title = "我的歌单";
        break;
      case 2:
        title = "设置";
        break;
    }

    //操作按钮
    List<Widget> actions;
    if (_currentIndex == 0) {
      actions = <Widget>[
        new IconButton(
            icon: new Icon(Icons.search),
            tooltip: '搜索',
            onPressed: () async {
              //获取配置后 跳转到歌单信息
              await ConfigDataService.read();
              await HisDataService.read();
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return SearchView();
              }));
            })
      ];
    } else if (_currentIndex == 1) {
      actions = <Widget>[
        new IconButton(
            icon: new Icon(Icons.add),
            tooltip: '添加我的歌单',
            onPressed: () {
              //弹出添加歌单界面
              _addSheet(context, _addSheetCallback);
            })
      ];
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: AppBar(
        title: Text(title),
        actions: actions,
        //左上角播放环形进度
        leading: InkWell(
          child: PlayerRingView(),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PlayerView();
            }));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //构造tab导航条
    final BottomNavigationBar bottomNavigationBar = new BottomNavigationBar(
        items: _navigationViews
            .map((NavigationIconView navigationIconView) =>
                navigationIconView.item)
            .toList(),
        currentIndex: _currentIndex,
        iconSize: 28.0,
        selectedFontSize: 8.0,
        unselectedFontSize: 8.0,
        elevation: 20.0,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _navigationViews[_currentIndex].controller.reverse();
            _currentIndex = index;
            _navigationViews[_currentIndex].controller.forward();
            // _currentPage = _pageList[_currentIndex];
          });
        });

    final _body = IndexedStack(
      children: _pageList,
      index: _currentIndex,
    );

    return Scaffold(
        appBar: _buildAppBar(),
        body: _body,
        bottomNavigationBar: bottomNavigationBar);
  }

  //添加歌单弹窗
  YYDialog _addSheet(
      BuildContext context, Function(String, MusicSource) callback) {
    var theme = Theme.of(context);
    var url = '';
    var source = MusicSource.unknow;

    return YYDialog().build(context)
      ..width = 240
      ..borderRadius = 10.0
      ..gravity = Gravity.center
      ..text(
        padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
        alignment: Alignment.topLeft,
        text: "添加歌单",
        color: theme.textTheme.bodyText1.color,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      )

      //来源选择
      ..widget(
          SheetAddView((text) => {url = text}, (value) => {source = value}))

      //确定取消按钮
      ..divider(color: theme.dividerColor)
      ..doubleButton(
        padding: EdgeInsets.only(top: 10.0),
        gravity: Gravity.center,
        withDivider: true,
        text1: "取消",
        color1: theme.primaryColor,
        fontSize1: 14.0,
        fontWeight1: FontWeight.w500,
        onTap1: () {},
        text2: "确定",
        color2: theme.primaryColor,
        fontSize2: 14.0,
        fontWeight2: FontWeight.w500,
        onTap2: () {
          callback.call(url, source);
        },
      )
      ..backgroundColor = theme.scaffoldBackgroundColor
      ..show();
  }

  //添加歌单回调
  Future<void> _addSheetCallback(url, source) async {
    //参数错误
    if (url == null || url == '' || source == MusicSource.unknow) {
      return;
    }
    try {
      //请求歌单信息
      var sheetInfo =
          await ApiService.getSheetInfo(source, url, showNotice: false);
      //添加到我的歌单
      var mySheetInfo = await MySheetsDataService.addMySheet(sheetInfo);
      sheetInfo = null;
      //打开歌单详情
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SheetInfoView(mySheetInfo);
      }));

      DialogView.showNoticeView('已添加至我的歌单',
          dissmissMilliseconds: 1000,
          context: context);
    } catch (exp) {
      DialogView.showNoticeView('歌单信息获取失败',
          icon: Icons.error_outline,
          dissmissMilliseconds: 1000,
          context: context);
    }
  }
}
