import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:whisper/service/data/cur_play_data_service.dart';
import 'package:whisper/service/http/api_service.dart';
import 'package:whisper/service/player_service.dart';
import 'package:whisper/view/common_view/dialog.dart';
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
        new Column(
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
        )
      ],
    );
  }

  bool _isReqestOver = false;
  _getRecom() {
    //请求推荐歌单
    ApiService.getRecomSheets().then((value) {
      _isReqestOver = true;

      //获取最近播放
      CurPlayDataService.read().then((cur) {
        //跳转
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return MainTab(value);
        }), (route) => route == null);

        //初始化播放服务
        var platform =  Theme.of(context).platform;
        PlayerService.build(platform);
      });
    });

    // 延时5s执行
    Future.delayed(Duration(seconds: 5), () {
      var times = 0;

      //检查结果
      while (!_isReqestOver) {
        sleep(Duration(microseconds: 500));
        times += 1;
        if (times == 10) {
          //十次失败 弹提示 可重试
          DialogView.showDialogView(
              "无法连接到网络，请在“设置”中允许Whisper访问网络后，点击重试", "重试", "取消", () {
            _getRecom();
          }, () {
            return;
          });
          break;
        }
      }
    });
  }
}
