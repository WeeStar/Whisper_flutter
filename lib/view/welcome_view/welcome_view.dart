import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:whisper/service/data/cur_play_data_service.dart';
import 'package:whisper/service/data/his_data_service.dart';
import 'package:whisper/service/data/my_sheets_data_service.dart';
import 'package:whisper/service/http/api_service.dart';
import 'package:whisper/service/play/curlist_service.dart';
import 'package:whisper/service/play/player_service.dart';
import 'package:whisper/view/common_view/dialog_view.dart';
import 'package:whisper/view/main_view/main_tab_view.dart';

class WelcomeView extends StatefulWidget {
  @override
  _WelcomeViewState createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    //获取推荐歌单
    _getRecom();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        new Image.asset('images/welcome/welcome_1.png',
            alignment: Alignment.center, fit: BoxFit.fitHeight),
        new SafeArea(
            child: Column(
          children: [
            new Padding(
              padding: new EdgeInsets.fromLTRB(0, 110, 0, 30),
              child: new Image.asset('images/logo/white.png',
                  alignment: Alignment.center, width: 120, height: 120),
            ),
            Expanded(
              child: new Text("音 乐 无 界     万 象 森 罗",
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none)),
            ),
            new Padding(
              padding: new EdgeInsets.fromLTRB(0, 0, 0, 60),
              child: new Text("Developed by WeeStar",
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none)),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ))
      ],
    );
  }

  _getRecom() async {
    var recomSheets = [];

    //请求推荐歌单
    var fgetRecom = new Future(() async {
      recomSheets = await ApiService.getRecomSheets();
    }).timeout(new Duration(seconds: 15));

    //初始化播放服务
    var finitPlay = new Future(() async {
      await CurPlayDataService.read(); //获取最近播放
      var platform = Theme.of(context).platform;
      PlayerService.build(platform);
      CurListService.build();
    });

    //读取数据
    var freadHis = HisDataService.read();
    var freadMy = MySheetsDataService.read();

    //打开主页
    Future.wait<dynamic>([fgetRecom, finitPlay, freadHis, freadMy])
        .then((value) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return MainTab(recomSheets);
      }), (route) => route == null);
    }).catchError((error) {
      DialogView.showDialogView(
          "无法连接到网络，请在“设置”中允许Whisper访问网络后，点击重试", "重试", "取消", () {
        _getRecom();
      }, () {
        return;
      });
    });
  }
}
