import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/service/data/my_sheets_data_service.dart';
import 'package:whisper/service/http/api_service.dart';
import 'package:whisper/service/play/player_service.dart';
import 'package:whisper/view/common_view/common_view.dart';
import 'package:whisper/view/common_view/dialog.dart';
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

  String title = "歌单"; //用于标题展示

  bool _isLoadingData = true; //加载数据节流
  bool _isSyncData = false; //同步歌单节流

  bool _isFav = false; //是否收藏
  bool _isFavSaving = false; //收藏节流

  _SheetInfoViewState(this._sheetInfo) {
    _coverImg = this._sheetInfo.cover_img_url;
    _title = this._sheetInfo.title;
  }

  @override
  void initState() {
    super.initState();

    //网络歌单 请求信息
    if ((_sheetInfo.tracks?.length ?? 0) == 0 && _sheetInfo.is_my != null) {
      _isLoadingData = true;
      ApiService.getSheetInfo(_sheetInfo.sheet_source, _sheetInfo.id)
          .then((sheetRes) {
        MySheetsDataService.isFavSheets(this._sheetInfo.id).then((value) {
          setState(() {
            _isLoadingData = false;
            _sheetInfo = sheetRes;
            _isFav = value;
          });
        });
      }).catchError((error) {
        return;
      });
    } else {
      _isLoadingData = false;
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
        DialogView.showNoticeView("同步完成", dissmissMilliseconds: 1000);
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

        DialogView.showNoticeView("已取消", dissmissMilliseconds: 1000);
      });
    } else {
      //未收藏 添加收藏
      MySheetsDataService.addFavSheet(_sheetInfo).then((value) {
        _isFavSaving = false;
        setState(() {
          _isFav = true;
        });

        DialogView.showNoticeView("已收藏", dissmissMilliseconds: 1000);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    var width = MediaQuery.of(context).size.width;

    //播放全部 行
    var playAll = Row(
      children: [
        Icon(
          Icons.play_circle_outline,
          color: Theme.of(context).textTheme.bodyText1.color,
          size: 20,
        ),
        SizedBox(
          width: 9,
        ),
        Text("播放全部", style: Theme.of(context).textTheme.bodyText1)
      ],
    );

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBar(
                title: Text(
                  title,
                  style: TextStyle(fontSize: title == "歌单" ? 20 : 15),
                ),
                actions: <Widget>[
                  _sheetInfo.is_my
                      ? new IconButton(
                          icon: new Icon(Icons.edit),
                          tooltip: '编辑歌单',
                          onPressed: () {})
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
        body: new NotificationListener(
          onNotification: (ScrollNotification note) {
            //监听滚动位置
            if (_title.isEmpty) return true;
            var offset = note.metrics.pixels.toInt();

            //变化标题
            if (offset > width * 0.4 && title == "歌单") {
              setState(() {
                title = _title;
              });
            } else if (offset < width * 0.4 && title != "歌单") {
              setState(() {
                title = "歌单";
              });
            }
            return true;
          },
          child: ListView.builder(
            itemCount:
                _isLoadingData ? 4 : ((_sheetInfo.tracks?.length ?? 0) + 3),
            itemBuilder: (context, idx) {
              if (idx == 0) {
                return SheetInfoCoverView(
                    _coverImg, _title, _sheetInfo.tracks?.length ?? 0);
              } else if (idx == 1) {
                //播放全部 行
                return InkWell(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                    alignment: Alignment.centerLeft,
                    child: playAll,
                  ),
                  onTap: () {
                    //播放全部歌曲
                    PlayerService.play(sheet: _sheetInfo);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return PlayerView();
                    }));
                  },
                );
              } else if (idx == 2) {
                return Divider(
                    height: 0.1, color: Theme.of(context).disabledColor);
              } else {
                if (_isLoadingData) {
                  //等待图
                  return CommonView.buildLoadingView(context);
                } else {
                  return InkWell(
                      child: MusicItemView(_sheetInfo.tracks[idx - 3],
                          musicIdx: idx - 2),
                      onTap: () {
                        if (_sheetInfo.tracks == null ||
                            _sheetInfo.tracks.length == 0) return;

                        //无效歌曲跳出
                        if (!_sheetInfo.tracks[idx - 3].isPlayable()) return;

                        //播放选中歌曲
                        PlayerService.play(
                            music: _sheetInfo.tracks[idx - 3],
                            sheet: _sheetInfo);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return PlayerView();
                        }));
                      });
                }
              }
            },
          ),
        ));
  }
}
