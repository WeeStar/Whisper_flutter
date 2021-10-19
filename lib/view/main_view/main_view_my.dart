import 'package:flutter/material.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/service/data/his_data_service.dart';
import 'package:whisper/service/data/my_sheets_data_service.dart';
import 'package:whisper/service/event_service.dart';
import 'package:whisper/view/sheet_view/my/sheet_my_his.dart';
import 'package:whisper/view/sheet_view/my/sheet_my_list.dart';
import 'package:whisper/view/sheet_view/my/sheet_my_tab_delegate.dart';

class MainViewMy extends StatefulWidget {
  @override
  State<MainViewMy> createState() => new _MainViewMyState();
}

class _MainViewMyState extends State<MainViewMy> with TickerProviderStateMixin {
  TabController _controller;

  List<SheetModel> _hisSheets = List<SheetModel>.empty(); //历史歌单
  List<SheetModel> _favSheets = List<SheetModel>.empty(); //收藏歌单
  List<SheetModel> _mySheets = List<SheetModel>.empty(); //我的歌单

  var event1;
  var event2;

  @override
  void initState() {
    super.initState();

    _hisSheets = HisDataService.playSheetHis;
    _favSheets = MySheetsDataService.favSheets;
    _mySheets = MySheetsDataService.mySheets;

    _controller = TabController(
        initialIndex: _mySheets.length > 0 ? 0 : 1, length: 2, vsync: this);

    //监听歌单历史刷新
    event1 = eventBus.on<SheetHisRefreshEvent>().listen((event) {
      if (mounted)
        setState(() {
          _hisSheets = HisDataService.playSheetHis;
        });
    });

    //监听我的歌单刷新
    event2 = eventBus.on<MySheetsRefreshEvent>().listen((event) {
      if (mounted)
        setState(() {
          _mySheets = MySheetsDataService.mySheets;
        });
    });
  }

  TabBar _buildTabBar() {
    return TabBar(
      labelPadding: EdgeInsets.symmetric(horizontal: 5),
      isScrollable: true,
      controller: _controller,
      labelColor: Theme.of(context).textTheme.bodyText1.color,
      labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),

      unselectedLabelColor: Theme.of(context).disabledColor, //tab标签未选中时的颜色
      unselectedLabelStyle: TextStyle(fontSize: 16),

      indicatorColor: Theme.of(context).primaryColor, //标签指示器的颜色
      indicatorSize: TabBarIndicatorSize.label, //标签指示器的宽度
      indicatorWeight: 3.0, //标签指示器的高度
      tabs: [Tab(text: "我的歌单"), Tab(text: "收藏歌单")],
    );
  }

  List<Widget> _buildHeader() {
    var list = <Widget>[];
    if (_hisSheets.length > 0) {
      //头部 历史播放
      list.add(SliverAppBar(
        elevation: 0,
        toolbarHeight: 181,
        floating: true,
        expandedHeight: 181,
        flexibleSpace: SheetMyHisView(_hisSheets),
        backgroundColor: Theme.of(context).canvasColor,
      ));
    }
    //tab指示器
    list.add(SliverPersistentHeader(
      pinned: true,
      delegate: StickyTabBarDelegate(
        child: _buildTabBar(),
      ),
    ));

    return list;
  }

  @override
  Widget build(BuildContext context) {
    //顶部冻结列表
    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return _buildHeader();
        },
        body: TabBarView(
          controller: _controller,
          children: [SheetMyListView(_mySheets), SheetMyListView(_favSheets)],
        ));
  }

  @override
  void dispose() {
    this.event1.cancel(); //取消事件监听
    this.event2.cancel(); //取消事件监听
    _controller.dispose();
    super.dispose();
  }
}
