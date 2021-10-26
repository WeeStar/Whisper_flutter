import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/view/sheet_view/info/sheet_info_view.dart';

class SheeBlockItemView extends StatelessWidget {
  final SheetModel sheet;
  SheeBlockItemView(this.sheet);

  @override
  Widget build(BuildContext context) {
    //歌单封面
    var cover = OctoImage(
      width: 85,
      height: 85,
      image: CachedNetworkImageProvider(sheet.cover_img_url ?? ""),
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
    var title = Text(sheet.title ?? "",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1!.color,
            fontSize: 12,
            fontWeight: FontWeight.w400));

    return InkWell(
      child: Container(
        alignment: Alignment.centerLeft,
        width: 85,
        margin: EdgeInsets.only(right: 10),
        child: Column(
          children: [
            //封面图
            Container(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: cover,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).disabledColor,
                    width: 0.3,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: title,
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
