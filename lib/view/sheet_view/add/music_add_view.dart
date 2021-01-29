import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/service/data/my_sheets_data_service.dart';
import 'package:whisper/view/common_view/dialog_view.dart';

class MusicAddView extends StatelessWidget {
  final List<SheetModel> sheetList = MySheetsDataService.mySheets;
  final MusicModel music;
  final Function(bool res) callback;

  MusicAddView(this.music, this.callback);

  Widget build(BuildContext context) {
    double totalHeight = MediaQuery.of(context).size.height * 0.5;

    return Stack(children: <Widget>[
      //背景头部
      Container(
        height: 25,
        width: double.infinity,
        color: Colors.black54,
      ),

      //前景
      Container(
        height: totalHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            //头部
            _buildHeader(context),

            //列表部分
            _buildList(context, totalHeight - 60)
          ],
        ),
      ),
    ]);
  }

  //创建头部
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        //拖动提示
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
            Text("添加到歌单",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyText1.color)),
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

  Widget _buildList(BuildContext context, double listHeight) {
    return Container(
      height: listHeight,
      child: ListView.builder(
        itemExtent: 70,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, idx) {
          return InkWell(
            child: _buildItem(context, sheetList[idx]),
            onTap: () async {
              Navigator.pop(context);
              var exist = await MySheetsDataService.existMusicMySheet(
                  sheetList[idx].id, music.id);
              if (exist) {
                this.callback?.call(false);
              } else {
                await MySheetsDataService.insertMusicMySheet(
                    sheetList[idx].id, music);
                this.callback?.call(true);
              }
            },
          );
        },
        itemCount: sheetList.length,
      ),
    );
  }

  //构造单个歌单
  Widget _buildItem(BuildContext context, SheetModel sheet) {
    //歌单封面
    var cover = OctoImage(
      width: 60,
      height: 60,
      image: CachedNetworkImageProvider(sheet.cover_img_url),
      placeholderBuilder: (_) {
        return Image.asset("images/empty.png",
            alignment: Alignment.center, fit: BoxFit.fill);
      },
      errorBuilder: (_, object, stracktrace) {
        return Image.asset("images/empty.png",
            alignment: Alignment.center, fit: BoxFit.fill);
      },
      fit: BoxFit.fill,
    );

    //歌单标题
    var title = Text(sheet.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyText1);

    return Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.centerLeft,
        height: 70,
        child: Row(
          children: [
            SizedBox(
              width: 20,
            ),
            //封面图
            Container(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: cover,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).disabledColor,
                    width: 0.3,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            SizedBox(
              width: 10,
            ),

            //描述
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "${sheet.tracks.length} 首歌曲",
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyText2,
                  )
                ],
              ),
            )
          ],
        ));
  }
}
