// Copyright (c) 2017, Spencer. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/service/data/config_data_service.dart';

typedef Widget AppBarCallback(BuildContext context);
typedef void TextFieldSubmitCallback(String value, MusicSource source);
typedef void TabChangeCallback(MusicSource source);
typedef void SetStateCallback(void fn());

class AppBarSearch {
  final TextFieldSubmitCallback onSubmitted; //提交事件
  final TabChangeCallback onTabChanged; //tab切换事件
  final VoidCallback onCleared; //清空事件
  final String hintText; //提示文字

  //上下文相关
  final TickerProvider provider;
  final SetStateCallback setState;

  TextEditingController _controller;
  TabController _tabController;

  bool _clearActive = false;

  //tab相关
  bool _isShowTab = false;
  int _tabIdx = 0;
  List<MusicSource> _sourceSeq;

  //构造
  AppBarSearch({
    @required this.provider,
    @required this.setState,
    this.hintText = 'Search',
    this.onSubmitted,
    this.onTabChanged,
    this.onCleared,
  }) {
    //异步 获取各平台展示顺序
    _sourceSeq = ConfigDataService.config.musicSourcSeq;

    //构造 textcontroller
    this._controller = TextEditingController();
    this._controller.addListener(() {
      if (this._controller.text.isEmpty && _clearActive) {
        setState(() {
          _clearActive = false;
        });
      } else if (this._controller.text.isNotEmpty && !_clearActive) {
        setState(() {
          _clearActive = true;
        });
      }
    });

    //构造tabcontroller
    this._tabController = TabController(
        initialIndex: _tabIdx, vsync: provider, length: _sourceSeq.length)
      ..addListener(() {
        if (_tabIdx == _tabController.index) return;
        _tabIdx = _tabController.index;
        onTabChanged?.call(_sourceSeq[_tabIdx]);
      });
  }

  //构造tab
  TabBar _buildSearchTab(BuildContext context) {
    return TabBar(
      isScrollable: true,
      labelPadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      labelColor: Colors.white,
      labelStyle: TextStyle(fontSize: 12),

      unselectedLabelColor: Colors.white38, //tab标签未选中时的颜色
      unselectedLabelStyle: TextStyle(fontSize: 12),

      indicatorColor: Colors.white, //标签指示器的颜色
      indicatorSize: TabBarIndicatorSize.label, //标签指示器的宽度
      indicatorWeight: 2.0, //标签指示器的高度

      tabs: this._sourceSeq.map((e) => Tab(text: e.desc)).toList(),
      controller: _tabController,
    );
  }

  //设置搜索文字
  setSearchText(String searchText) {
    _controller.text = searchText; 
    //展示tab
    setState(() {
      _isShowTab = true;
    });
    onSubmitted?.call(searchText, _sourceSeq[_tabIdx]);
  }

  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize:
            Size.fromHeight(_isShowTab && _sourceSeq != null ? 98 : 50),
        child: AppBar(
          title: Directionality(
            textDirection: Directionality.of(context),
            //输入框
            child: TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.white38,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none),
              onSubmitted: (String val) async {
                //展示tab
                setState(() {
                  _isShowTab = true;
                });
                onSubmitted?.call(val, _sourceSeq[_tabIdx]);
              },
              autofocus: _isShowTab ? false : true,
              style: TextStyle(fontSize: 16, color: Colors.white),
              controller: _controller,
            ),
          ),
          actions: <Widget>[
            //清空
            IconButton(
                icon: Icon(Icons.clear),
                disabledColor: Colors.white38,
                onPressed: !_clearActive
                    ? null
                    : () {
                        //隐藏tab
                        setState(() {
                          _isShowTab = false;
                        });
                        onCleared?.call();
                        _controller.clear();
                      })
          ],
          //底部tab页签
          bottom: _isShowTab && _sourceSeq != null
              ? PreferredSize(
                  preferredSize: Size.fromHeight(20),
                  child: _buildSearchTab(context))
              : null,
        ));
  }
}
