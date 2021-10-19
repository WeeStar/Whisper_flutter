import 'package:flutter/material.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/service/http/api_service.dart';
import 'package:whisper/view/sheet_view/item/sheet_list_item.dart';
import 'package:whisper/view/sheet_view/recom/sheet_recom_more.dart';

class SheetRecomListView extends StatelessWidget {
  final RecomModel recomList;
  SheetRecomListView(this.recomList);

  //满三个拆分
  List<List<SheetModel>> _splitRecomList() {
    var sheetGroup = <List<SheetModel>>[];
    var sheetList = <SheetModel>[];
    for (var item in recomList.sheets) {
      sheetList.add(item);
      if (sheetList.length == 3) {
        sheetGroup.add(sheetList);
        sheetList = <SheetModel>[];
      }
    }
    if (sheetList.length > 0) {
      sheetGroup.add(sheetList);
    }
    return sheetGroup;
  }

  //满三个拆分
  List<List<Widget>> _getListItems(List<List<SheetModel>> sheetGroup) {
    var listItems = <List<Widget>>[];
    for (var group in sheetGroup) {
      var columnItems = <Widget>[];
      for (var item in group) {
        columnItems.add(new SheetListItemView(item));
      }
      //补全空白
      if (columnItems.length < 3) {
        columnItems.add(SizedBox(height: 80));
      }
      listItems.add(columnItems);
    }
    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    //标题
    var title = Text(
      recomList.source.desc,
      style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).textTheme.bodyText1.color,
          fontWeight: FontWeight.w600),
    );

    //查看更多
    var more = InkWell(
      child: Text(
        "查看更多",
        style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w400),
      ),
      onTap: () {
        //跳转到歌单信息
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SheetRecomMoreView(recomList.source, recomList.sheets);
        }));
      },
    );

    var header = Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [title, more],
      ),
    );

    //歌单3个一组
    var sheetGroup = _splitRecomList();
    var listItems = _getListItems(sheetGroup);

    var sheetsList = ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, idx) {
        if (idx == 0) {
          return SizedBox(
            width: 5,
          );
        }
        return Column(
          children: listItems[idx - 1],
        );
      },
      itemCount: listItems.length+1,
    );

    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top:15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          header,
          Container(
              alignment: Alignment.centerLeft, height: 240, child: sheetsList)
        ],
      ),
    );
  }
}
