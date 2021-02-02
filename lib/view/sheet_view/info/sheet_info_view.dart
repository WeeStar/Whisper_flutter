import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/service/data/my_sheets_data_service.dart';
import 'package:whisper/service/http/api_service.dart';
import 'package:whisper/service/play/player_service.dart';
import 'package:whisper/view/common_view/common_view.dart';
import 'package:whisper/view/common_view/dialog_view.dart';
import 'package:whisper/view/music_view/music_item_view.dart';
import 'package:whisper/view/sheet_view/info/sheet_info_cover.dart';
import 'package:whisper/view/player_view/player_view.dart';

class SheetInfoView extends StatefulWidget {
  SheetInfoView(this._sheetInfo);
  final SheetModel _sheetInfo;

  @override
  State<SheetInfoView> createState() => new _SheetInfoViewState(_sheetInfo);
}

class _SheetInfoViewState extends State<SheetInfoView>
    with TickerProviderStateMixin {
  SheetModel _sheetInfo;

  String _coverImg; //封面图片用于避开setState重新加载
  String _title; //歌单标题用于避开setState重新加载

  //滚动检测
  double _width = 100.0;
  String _viewTitle = "歌单"; //用于标题展示
  ScrollController _controller = ScrollController();
  AnimationController _hideFabAnimation;

  bool _isLoadingData = true; //加载数据节流
  bool _isSyncData = false; //同步歌单节流

  bool _isFav = false; //是否收藏
  bool _isFavSaving = false; //收藏节流
  bool _isDeleting = false; //删除节流

  _SheetInfoViewState(this._sheetInfo) {
    _coverImg = this._sheetInfo.cover_img_url;
    _title = this._sheetInfo.title;
  }

  @override
  void initState() {
    super.initState();

    //滚动与fab显示隐藏动画
    _controller.addListener(_listener);
    _hideFabAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);

    if (!_sheetInfo.is_my && (_sheetInfo.tracks?.length ?? 0) == 0) {
      //网络歌单 请求信息
      _isLoadingData = true;
      ApiService.getSheetInfo(_sheetInfo.sheet_source, _sheetInfo.id)
          .then((sheetRes) {
        setState(() {
          _isLoadingData = false;
          _sheetInfo = sheetRes;
        });
      }).catchError((error) {
        return;
      });
    } else if (_sheetInfo.is_my && (_sheetInfo.tracks?.length ?? 0) == 0) {
      //本地歌单历史记录 请求信息
      var sheetRes = MySheetsDataService.mySheets.firstWhere(
          (element) => element.id == _sheetInfo.id,
          orElse: () => null);
      if (sheetRes != null) {
        setState(() {
          _isLoadingData = false;
          _sheetInfo = sheetRes;
        });
      }
    } else {
      _isLoadingData = false;
    }

    //判断是否我的歌单
    if (!_sheetInfo.is_my) {
      MySheetsDataService.isFavSheets(this._sheetInfo.id).then((value) {
        setState(() {
          _isFav = value;
        });
      });
    }
  }

  //同步歌单
  void _syncSheet() {
    if (!_sheetInfo.is_my) return;

    //节流
    if (_isLoadingData || _isSyncData) return;
    _isSyncData = true;

    //云端歌单数据同步本地
    ApiService.getSheetInfo(_sheetInfo.sheet_source, _sheetInfo.id)
        .then((sheetRes) {
      MySheetsDataService.addMySheet(sheetRes).then((mySheet) {
        _isSyncData = false;
        setState(() {
          _sheetInfo = mySheet;
        });
        DialogView.showNoticeView("同步完成",
            dissmissMilliseconds: 1000, width: 120);
      });
    });
  }

  //收藏歌单
  void _faveSheet() {
    if (_sheetInfo.is_my) return;

    //节流
    if (_isLoadingData || _isFavSaving) return;
    _isFavSaving = true;

    if (_isFav) {
      //已收藏 取消收藏
      MySheetsDataService.delFavSheet(_sheetInfo.id).then((value) {
        _isFavSaving = false;
        if (!value) return;
        setState(() {
          _isFav = false;
        });

        DialogView.showNoticeView("已取消",
            dissmissMilliseconds: 1000, width: 120);
      });
    } else {
      //未收藏 添加收藏
      MySheetsDataService.addFavSheet(_sheetInfo).then((value) {
        _isFavSaving = false;
        setState(() {
          _isFav = true;
        });

        DialogView.showNoticeView("已收藏",
            dissmissMilliseconds: 1000, width: 120);
      });
    }
  }

  //删除歌单
  void _delSheet() {
    if (!_sheetInfo.is_my) return;

    //节流
    if (_isLoadingData || _isDeleting) return;
    _isDeleting = true;

    DialogView.showDialogView("是否删除歌单", "确定", "取消", () {
      //删除歌单
      MySheetsDataService.delMySheet(_sheetInfo.id);
      //跳出
      Navigator.pop(context);
      _isDeleting = false;
    }, () {
      _isDeleting = false;
    });
  }

  ListView _buildList() {
    var list = ListView.builder(
      controller: _controller,
      itemCount: _isLoadingData ? 3 : ((_sheetInfo.tracks?.length ?? 0) + 2),
      itemBuilder: (context, idx) {
        if (idx == 0) {
          return SheetInfoCoverView(
              _coverImg, _title, _sheetInfo.tracks?.length ?? 0);
        } else if (idx == 1) {
          return Divider(
            height: 1,
          );
        } else {
          if (_isLoadingData) {
            //等待图
            return CommonView.buildLoadingView(context);
          } else {
            return InkWell(
                child: MusicItemView(_sheetInfo.tracks[idx - 2],
                    musicIdx: idx - 1),
                onTap: () {
                  if (_sheetInfo.tracks == null ||
                      _sheetInfo.tracks.length == 0) return;

                  //无效歌曲跳出
                  if (!_sheetInfo.tracks[idx - 2].isPlayable()) return;

                  //播放选中歌曲
                  PlayerService.play(
                      music: _sheetInfo.tracks[idx - 2], sheet: _sheetInfo);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PlayerView();
                  }));
                });
          }
        }
      },
    );
    return list;
  }

  //滚动监听
  void _listener() {
    //向下滚动隐藏fab
    switch (_controller.position.userScrollDirection) {
      case ScrollDirection.forward:
        if (_controller.position.maxScrollExtent !=
            _controller.position.minScrollExtent) {
          _hideFabAnimation.reverse();
        }
        break;
      case ScrollDirection.reverse:
        if (_controller.position.maxScrollExtent !=
            _controller.position.minScrollExtent) {
          _hideFabAnimation.forward();
        }
        break;
      case ScrollDirection.idle:
        break;
    }

    //滚动修改标题
    if (_title.isEmpty) return;
    var offset = _controller.offset;

    //变化标题
    if (offset > _width * 0.25 && _viewTitle == "歌单") {
      setState(() {
        _viewTitle = _title;
      });
    } else if (offset < _width * 0.25 && _viewTitle != "歌单") {
      setState(() {
        _viewTitle = "歌单";
      });
    }
  }

  //构造fab
  Widget _buildFab() {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 30, 30),
        child: ScaleTransition(
            scale: Tween(begin: 1.0, end: 0.0).animate(_hideFabAnimation)
              ..addListener(() {
                setState(() {});
              }),
            alignment: Alignment.center,
            child: FloatingActionButton(
              tooltip: "播放全部",
              child: Icon(
                Icons.play_arrow,
                size: 35,
              ),
              onPressed: () {
                //播放全部歌曲
                PlayerService.play(sheet: _sheetInfo);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return PlayerView();
                }));
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
        floatingActionButton: _buildFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBar(
                title: Text(
                  _viewTitle,
                  style: TextStyle(fontSize: _viewTitle == "歌单" ? 20 : 15),
                ),
                actions: <Widget>[
                  _sheetInfo.is_my
                      ? new IconButton(
                          icon: new Icon(Icons.delete),
                          tooltip: '删除歌单',
                          onPressed: _delSheet)
                      : new IconButton(
                          icon:
                              new Icon(_isFav ? Icons.star : Icons.star_border),
                          tooltip: _isFav ? '取消收藏' : '收藏歌单',
                          onPressed: _faveSheet),
                  _sheetInfo.is_my
                      ? new IconButton(
                          icon: new Icon(Icons.cloud_download),
                          tooltip: "同步歌单",
                          onPressed: _syncSheet)
                      : new IconButton(
                          icon: new Icon(Icons.share),
                          tooltip: "分享歌单",
                          onPressed: () {}),
                ])),
        body: _buildList());
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideFabAnimation.dispose();
    super.dispose();
  }
}
