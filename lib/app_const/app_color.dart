import 'package:flutter/material.dart';

class AppColor {
  //主题色
  static final Color themeColorLight = const Color.fromARGB(255, 229, 90, 66);
  static final Color themeColorDark = const Color.fromARGB(255, 229, 84, 75);

  //主背景色
  static final Color bgColorMainLight =
      const Color.fromARGB(255, 255, 255, 255);
  static final Color bgColorMainDark = const Color.fromARGB(255, 45, 45, 47);

  //副背景色
  static final Color bgColorSubLight = const Color.fromARGB(255, 225, 227, 230);
  static final Color bgColorSubDark = const Color.fromARGB(255, 64, 64, 64);

  //主文字色
  static final Color textColorMainLight = Colors.black;
  static final Color textColorMainDark =
      const Color.fromARGB(255, 207, 207, 207);

  //副文字色
  static final Color textColorSubLight = Colors.grey[500];
  static final Color textColorSubDark =
      const Color.fromARGB(255, 116, 116, 117);

  //图片上文字色
  static final Color textColorOnImgLight = Colors.white;
  static final Color textColorOnImgDark =
      const Color.fromARGB(200, 255, 255, 255);

  //进度条色
  static final Color prgBarForeColor = const Color.fromARGB(255, 210, 211, 212);
  static final Color prgBarBackColor = const Color.fromARGB(255, 145, 145, 147);

  //亮主题
  static final ThemeData themeDataLight = ThemeData(
    brightness: Brightness.light,

    //主题色
    primaryColor: AppColor.themeColorLight,
    accentColor: AppColor.themeColorLight,

    disabledColor: AppColor.textColorSubLight,

    // Tab指示器颜色
    indicatorColor: AppColor.themeColorLight,

    // 页面背景色
    scaffoldBackgroundColor: AppColor.bgColorMainLight,
    backgroundColor: AppColor.bgColorSubLight,
    // 主要用于Material背景色
    canvasColor: AppColor.bgColorMainLight,

    textTheme: new TextTheme(
        bodyText1: new TextStyle(
            color: AppColor.textColorMainLight,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none),
        bodyText2: new TextStyle(
            color: AppColor.textColorSubLight,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none),
        subtitle1: new TextStyle(
            color: AppColor.textColorOnImgLight,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none)),

    //分割线颜色
    dividerTheme: DividerThemeData(
        color: Colors.grey[200], space: 0.6, thickness: 0.6),
  );

  //暗主题
  static final ThemeData themeDataDark = ThemeData(
    brightness: Brightness.dark,

    //主题色
    primaryColor: AppColor.themeColorDark,
    accentColor: AppColor.themeColorDark,

    disabledColor: AppColor.textColorSubDark,

    // Tab指示器颜色
    indicatorColor: AppColor.themeColorDark,

    // 页面背景色
    scaffoldBackgroundColor: AppColor.bgColorMainDark,
    backgroundColor: AppColor.bgColorSubDark,
    // 主要用于Material背景色
    canvasColor: AppColor.bgColorMainDark,

    textTheme: new TextTheme(
        bodyText1: new TextStyle(
            color: AppColor.textColorMainDark,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none),
        bodyText2: new TextStyle(
            color: AppColor.textColorSubDark,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none),
        subtitle1: new TextStyle(
            color: AppColor.textColorOnImgDark,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none)),

    //分割线颜色
    dividerTheme: DividerThemeData(
        color: Colors.grey[700], space: 0.6, thickness: 0.6),
  );
}
