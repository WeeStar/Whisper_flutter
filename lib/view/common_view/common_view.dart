import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:whisper/model/music_model.dart';

class CommonView {
  //创建loading等待组件
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

  //创建sheet菜单组件
  static buildMenuSheetView(BuildContext context, MusicModel music,
      List<MenuSheetItemModel> menuItems) {
    return SafeArea(
        child: Stack(children: <Widget>[
      //背景头部
      Container(
        height: 25,
        width: double.infinity,
        color: Colors.black54,
      ),

      //列表部分
      Container(
        height: 80 + 47.0 * menuItems.length,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            _buildMenuSheetHeader(context, music),
            Divider(
              height: 1,
            ),
            Container(
              height: 47.0 * menuItems.length,
              child: ListView.builder(
                itemExtent: 47,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, idx) {
                  return _buildMenuSheetItem(context, menuItems[idx]);
                },
                itemCount: menuItems.length,
              ),
            )
          ],
        ),
      ),
    ]));
  }

  //创建头部
  static Widget _buildMenuSheetHeader(BuildContext context, MusicModel music) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 6, 0, 6),
          width: 45,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor,
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
        ),

        //标题行
        Row(
          textBaseline: TextBaseline.ideographic,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            SizedBox(
              width: 25,
            ),
            Expanded(
                child: Text(music.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyText1.color))),
            SizedBox(
              width: 25,
            ),
          ],
        ),

        SizedBox(
          height: 3,
        ),

        //副标题行
        Row(
          textBaseline: TextBaseline.ideographic,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 25,
            ),
            Image.asset(
              "images/icon/${music.source.name}.png",
              fit: BoxFit.fill,
              width: 14,
              height: 14,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
                child: Text(music.getDesc(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).disabledColor))),
            SizedBox(
              width: 25,
            ),
          ],
        ),

        SizedBox(
          height: 10,
        )
      ],
    );
  }

  //创建菜单项
  static Widget _buildMenuSheetItem(
      BuildContext context, MenuSheetItemModel item) {
    return InkWell(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
            ),

            //图标
            Container(
              child: Icon(item.icon,
                  size: 25,
                  color: item.enable
                      ? Theme.of(context).textTheme.bodyText1.color
                      : Theme.of(context).disabledColor),
              alignment: Alignment.center,
              width: 40,
            ),
            SizedBox(
              width: 5,
            ),

            //功能文字
            Text(
              item.title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: item.enable
                      ? Theme.of(context).textTheme.bodyText1.color
                      : Theme.of(context).disabledColor),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (!item.enable) return;
        item.callBack?.call();
      },
    );
  }
}

class MenuSheetItemModel {
  MenuSheetItemModel(this.title, this.icon, this.callBack,
      {this.enable = true});

  String title;
  IconData icon;
  Function callBack;
  bool enable;
}
