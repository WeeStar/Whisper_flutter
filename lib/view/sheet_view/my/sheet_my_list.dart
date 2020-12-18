import 'package:flutter/material.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/view/sheet_view/item/sheet_list_item.dart';

class SheetMyListView extends StatelessWidget {
  final List<SheetModel> _sheetList;
  SheetMyListView(this._sheetList);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(left: 8),
      itemBuilder: (context, idx) {
        if (_sheetList.length == 0 && idx == 0)
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 15),
            child: Text(
              "暂无歌单数据",
              style: TextStyle(
                  color: Theme.of(context).disabledColor, fontSize: 12),
            ),
          );
        else if (_sheetList.length > 0 && idx == 0)
          return SizedBox(
            height: 10,
          );
        return SheetListItemView(_sheetList[idx - 1]);
      },
      itemCount: _sheetList.length + 1,
    );
  }
}
