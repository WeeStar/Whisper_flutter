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

  MusicAddView(this.music);

  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      //背景头部
      Container(
        height: 25,
        width: double.infinity,
        color: Colors.black54,
      ),

      //列表部分
      Container(
        height: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Divider(
              height: 1,
            ),
            Container(
              height: 450,
              child: ListView.builder(
                itemBuilder: (context, idx) {
                  return InkWell(
                    child: _buildItem(context, sheetList[idx]),
                    onTap: () async {
                      var exist = await MySheetsDataService.existMusicMySheet(
                          sheetList[idx].id, music.id);
                      if (exist) {
                        DialogView.showNoticeView('当前歌曲已存在',
                            dissmissMilliseconds: 1000, context: context);
                      } else {
                        await MySheetsDataService.insertMusicMySheet(
                            sheetList[idx].id, music);
                        DialogView.showNoticeView('已添加',
                            dissmissMilliseconds: 1000, context: context);
                      }
                      Navigator.pop(context);
                    },
                  );
                },
                itemCount: sheetList.length,
              ),
            )
          ],
        ),
      ),
    ]);
  }

  //创建头部
  static Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 4, 0, 10),
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
                child: Text("添加到歌单",
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
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  //构造单个
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
        alignment: Alignment.centerLeft,
        height: 68,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 8),
        child: Row(
          children: [
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
