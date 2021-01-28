import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/service/data/my_sheets_data_service.dart';
import 'package:whisper/service/http/api_service.dart';
import 'package:whisper/view/sheet_view/add/sheet_add_view.dart';
import 'package:whisper/view/sheet_view/info/sheet_info_view.dart';

class DialogView {
  //显示提示
  static YYDialog showNoticeView(String noticeMsg,
      {IconData icon = Icons.check_circle_outline,
      int dissmissMilliseconds = 0,
      double width = 200,
      BuildContext context}) {
    var notice = YYDialog().build(context)
      ..width = width
      ..height = 100
      ..borderRadius = 10.0
      ..barrierColor = Colors.transparent;
    //内部构造
    notice.widget(Padding(
        padding: EdgeInsets.only(top: 15),
        child: Icon(
          icon,
          size: 40,
          color: Theme.of(notice.context)
              .textTheme
              .bodyText1
              .color
              .withOpacity(0.7),
        )))
      ..widget(Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text(
          noticeMsg,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(notice.context)
                  .textTheme
                  .bodyText1
                  .color
                  .withOpacity(0.7)),
        ),
      ))
      ..backgroundColor =
          Theme.of(notice.context).backgroundColor.withOpacity(0.8)

      //定时消失
      ..showCallBack = dissmissMilliseconds > 0
          ? () {
              Future.delayed(Duration(milliseconds: dissmissMilliseconds), () {
                notice?.dismiss();
              });
            }
          : null
      ..show();

    return notice;
  }

  //显示对话框
  static YYDialog showDialogView(String text, String tab1Text, String tab2Text,
      VoidCallback onTap1, VoidCallback onTap2) {
    var dialog = YYDialog().build()..borderRadius = 5.0;

    var theme = Theme.of(dialog.context);
    var width = MediaQuery.of(dialog.context).size.width;

    return dialog
      ..width = width * 0.7
      ..text(
        padding: EdgeInsets.all(20.0),
        text: text,
        color: theme.textTheme.bodyText1.color,
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      )
      ..doubleButton(
        gravity: Gravity.right,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
        text1: tab1Text,
        color1: theme.primaryColor,
        fontSize1: 15.0,
        fontWeight1: FontWeight.w500,
        onTap1: () {
          onTap1?.call();
        },
        text2: tab2Text,
        color2: theme.primaryColor,
        fontSize2: 15.0,
        fontWeight2: FontWeight.w500,
        onTap2: () {
          onTap2?.call();
        },
      )
      ..backgroundColor = Theme.of(dialog.context).scaffoldBackgroundColor
      ..show();
  }

//显示添加我的歌单弹窗
  static YYDialog showAddMySheetDialog(BuildContext context) {
    var theme = Theme.of(context);
    var width = MediaQuery.of(context).size.width;
    var url = '';
    var source = MusicSource.unknow;

    return YYDialog().build(context)
      ..width = width * 0.7
      ..borderRadius = 5.0
      ..gravity = Gravity.center
      ..text(
        padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
        alignment: Alignment.topLeft,
        text: "导入歌单",
        color: theme.textTheme.bodyText1.color,
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      )

      //来源选择
      ..widget(
          SheetAddView((text) => {url = text}, (value) => {source = value}))

      //确定取消按钮
      ..doubleButton(
        gravity: Gravity.right,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
        text1: "确定",
        color1: theme.primaryColor,
        fontSize1: 15.0,
        fontWeight1: FontWeight.w500,
        onTap1: () {
          _addSheetCallback.call(context, url, source);
        },
        text2: "取消",
        color2: theme.primaryColor,
        fontSize2: 15.0,
        fontWeight2: FontWeight.w500,
        onTap2: () {},
      )
      ..backgroundColor = theme.scaffoldBackgroundColor
      ..show();
  }

  //添加歌单回调
  static Future<void> _addSheetCallback(
      BuildContext context, String url, MusicSource source) async {
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
          dissmissMilliseconds: 1000, context: context);
    } catch (exp) {
      DialogView.showNoticeView('歌单信息获取失败',
          icon: Icons.error_outline,
          dissmissMilliseconds: 1000,
          context: context);
    }
  }
}
