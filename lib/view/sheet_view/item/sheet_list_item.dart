import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/service/util.dart';
import 'package:whisper/view/sheet_view/info/sheet_info_view.dart';

class SheetListItemView extends StatelessWidget {
  final double widthScale;
  final SheetModel sheet;
  SheetListItemView(this.sheet, [this.widthScale = 0.9]);

  @override
  Widget build(BuildContext context) {
    var width = widthScale * MediaQuery.of(context).size.width;
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

    //描述
    var descChilden = new List<Widget>();
    if (sheet.is_my) {
      //我的歌单 展示歌曲数量
      descChilden.add(Text(
        "${sheet.tracks.length} 首歌曲",
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyText2,
      ));
    } else if (sheet.play == null || sheet.play.isEmpty) {
      //非我的歌单 播放量为空 展示点击播放
      descChilden.add(Icon(Icons.play_circle_outline,
          size: 16, color: Theme.of(context).disabledColor));
      descChilden.add(SizedBox(
        width: 3,
      ));
      descChilden.add(Text(
        "点击播放",
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyText2,
      ));
    } else {
      //非我的歌单 播放量不为空 展示播放量
      descChilden.add(Text(
        Util.playNumsFormat(sheet.play) + " 次播放",
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyText2,
      ));
    }

    var desc = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: descChilden,
    );

    return InkWell(
      child: Container(
        alignment: Alignment.centerLeft,
        width: width,
        height: 76,
        padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
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
                  desc
                ],
              ),
            )
          ],
        ),
      ),
      onTap: () {
        //跳转到歌单信息
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SheetInfoView(sheet);
        }));
      },
    );
  }
}
