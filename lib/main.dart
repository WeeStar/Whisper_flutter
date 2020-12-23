import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whisper/app_const/app_color.dart';
import 'package:whisper/view/welcome_view/welcome_view.dart';

void main() {
  runApp(MyApp());
  //黑色
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {     
    return new MaterialApp(
      title: 'Whisper',

      theme: AppColor.themeDataLight,
      darkTheme: AppColor.themeDataDark,

      home: new WelcomeView(),
      builder: (context, widget) {
        return MediaQuery(
          //设置文字大小不随系统设置改变
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: widget,
        );
      },
    );
  }
}
