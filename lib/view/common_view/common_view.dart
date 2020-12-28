import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  static buildMenuSheetView(
      BuildContext context, String title, List<MenuSheetItemModel> menuItems) {
    return Stack(children: <Widget>[
      //背景头部
      Container(
        height: 25,
        width: double.infinity,
        color: Colors.black54,
      ),

      //歌单列表部分
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        height: 50.0 + menuItems.length * 45,
        child: ListView.builder(
          itemExtent: 45,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, idx) {
            if (idx == 0) {
              return SizedBox(
                height: 50,
              );
            }
            return _buildMenuSheetItem(context, menuItems[idx - 1]);
          },
          itemCount: menuItems.length + 1,
        ),
      ),

      //头部
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        width: double.infinity,
        height: 48,
        child: _buildMenuSheetHeader(context, title),
      )
    ]);
  }

  //创建头部
  static Widget _buildMenuSheetHeader(BuildContext context, String title) {
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
        Row(
          textBaseline: TextBaseline.ideographic,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            SizedBox(
              width: 25,
            ),
            Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyText1.color))),
            SizedBox(
              width: 25,
            ),
          ],
        )
      ],
    );
  }

  static Widget _buildMenuSheetItem(
      BuildContext context, MenuSheetItemModel item) {
    return InkWell(
      child: Container(
        width: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
            ),
            Container(
              child: Icon(item.icon,
                  size: 30, color: Theme.of(context).disabledColor),
              alignment: Alignment.center,
              width: 40,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              item.title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyText1.color),
            )
          ],
        ),
      ),
      onTap: item.callBack,
    );
  }
}

class MenuSheetItemModel {
  MenuSheetItemModel(this.title, this.icon, this.callBack);

  String title;
  IconData icon;
  Function callBack;
}
