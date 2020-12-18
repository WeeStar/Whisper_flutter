import 'package:flutter/material.dart';

class MainViewSetting extends StatefulWidget {
  @override
  State<MainViewSetting> createState() => new _MainViewSettingState();
}

class _MainViewSettingState extends State<MainViewSetting>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Text(
            "设置",
            style: TextStyle(fontSize: 40),
          ),
        ));
  }
}
