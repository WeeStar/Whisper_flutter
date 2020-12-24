import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';

class DialogView {
  static YYDialog showNoticeView(String noticeMsg,
      {IconData icon = Icons.check_circle_outline,
      int dissmissMilliseconds = 0,double width = 160}) {
    var notice = YYDialog().build()
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
        padding: EdgeInsets.only(top: 5),
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

  //构造对话框
  static YYDialog showDialogView(String text, String tab1Text, String tab2Text,
      VoidCallback onTap1, VoidCallback onTap2,{double width = 200}) {
    var dialog = YYDialog().build()
      ..width = width
      ..borderRadius = 10.0;

    var theme = Theme.of(dialog.context);

    return dialog
      ..text(
        padding: EdgeInsets.all(20.0),
        alignment: Alignment.center,
        text: text,
        color: theme.textTheme.bodyText1.color,
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
      )
      ..divider(color: Theme.of(dialog.context).dividerColor)
      ..doubleButton(
        gravity: Gravity.center,
        withDivider: true,

        text1: tab1Text,
        color1: theme.primaryColor,
        fontSize1: 14.0,
        fontWeight1: FontWeight.bold,
        onTap1: () {
          onTap1?.call();
        },
        text2: tab2Text,
        color2: theme.primaryColor,
        fontSize2: 14.0,
        fontWeight2: FontWeight.w400,
        onTap2: () {
          onTap2?.call();
        },
      )
      ..backgroundColor =
          Theme.of(dialog.context).scaffoldBackgroundColor
      ..show();
  }
}
