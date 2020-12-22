import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';

class DialogView {
  static YYDialog showNoticeView(String noticeMsg,
      {IconData icon = Icons.check_circle_outline,
      int dissmissMilliseconds = 0}) {
    var notice = YYDialog().build()
      ..width = 120
      ..height = 110
      ..borderRadius = 10.0;

    //内部构造
    notice.widget(Padding(
        padding: EdgeInsets.only(top: 20),
        child: Icon(
          icon,
          size: 40,
          color: Theme.of(notice.context)
              .textTheme
              .bodyText1
              .color
              .withOpacity(0.9),
        )))
      ..widget(Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(
          noticeMsg,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(notice.context)
                  .textTheme
                  .bodyText1
                  .color
                  .withOpacity(0.9)),
        ),
      ))
      ..backgroundColor =
          Theme.of(notice.context).backgroundColor.withOpacity(0.8)
      // ..barrierColor = Theme.of(notice.context).backgroundColor.withOpacity(0.2)

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
      VoidCallback onTap1, VoidCallback onTap2) {
    var dialog = YYDialog().build()
      ..width = 220
      ..borderRadius = 4.0;

    var theme = Theme.of(dialog.context);

    return dialog
      ..text(
        padding: EdgeInsets.all(25.0),
        alignment: Alignment.center,
        text: text,
        color: theme.textTheme.bodyText1.color,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      )
      ..divider()
      ..doubleButton(
        padding: EdgeInsets.only(top: 10.0),
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
        fontWeight2: FontWeight.bold,
        onTap2: () {
          onTap2?.call();
        },
      )
      ..show();
  }
}