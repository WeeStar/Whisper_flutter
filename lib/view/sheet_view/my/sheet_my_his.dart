import 'package:flutter/material.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/view/sheet_view/item/sheet_block_item.dart';

class SheetMyHisView extends StatelessWidget {
  final List<SheetModel> _curList;
  SheetMyHisView(this._curList);

  @override
  Widget build(BuildContext context) {
    //标题
    var title = Text(
      "最近播放",
      style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).textTheme.bodyText1!.color,
          fontWeight: FontWeight.w500),
    );

    return Container(
      padding: EdgeInsets.only(top: 15),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //标题
          Padding(
            child: title,
            padding: EdgeInsets.only(left: 15),
          ),
          SizedBox(
            height: 8,
          ),
          //下方滚动列表
          Container(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, position) {
                  if (position == 0) {
                    return SizedBox(
                      width: 15,
                    );
                  }
                  return SheeBlockItemView(_curList[position - 1]);
                },
                itemCount: _curList.length + 1,
              ))
        ],
      ),
    );
  }
}
