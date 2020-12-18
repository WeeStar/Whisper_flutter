import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CommonView {
  static buildLoadingView(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitRing(
              lineWidth: 2,
              color: Theme.of(context).textTheme.bodyText1.color,
              size: 20,
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "正在加载,请稍后...",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color,
                      fontSize: 16),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "音乐无界  万象森罗",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 12),
                ),
              ],
            )
          ],
        ));
  }
}
