import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/service/util.dart';

class BannerItemView extends StatelessWidget {
  final SheetModel sheet;
  BannerItemView(this.sheet);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    //背景歌单封面
    var cover = OctoImage(
      height: width * 0.8,
      width: width,
      image: CachedNetworkImageProvider(sheet.ori_cover_img_url ?? ""),
      placeholderBuilder: (_) {
        return Image.asset("images/empty.png",
            alignment: Alignment.center, fit: BoxFit.fill);
      },
      errorBuilder: (_, object, stracktrace) {
        return Image.asset("images/empty.png",
            alignment: Alignment.center, fit: BoxFit.fill);
      },
      fit: BoxFit.cover,
    );

    //右上角播放次数
    var playTimes = Text(
      Util.playNumsFormat(sheet.play ?? "0") + " 次播放",
      maxLines: 1,
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.subtitle1?.color),
    );

    //下部描述文字
    var descText = TextSpan(
      text: sheet.title,
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.subtitle1?.color),
    );

    //下部描述图标
    var descIcon = Image.asset(
      "images/icon/${sheet.sheet_source.name}.png",
      width: 18,
      height: 18,
    );

    var desc = ClipRRect(
      child: BackdropFilter(
        //模糊背景
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 70,
          alignment: Alignment.topLeft,
          decoration: new BoxDecoration(
              color: Theme.of(context).backgroundColor.withOpacity(0.5)),
          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Text.rich(
                  TextSpan(children: [
                    //来源图标
                    WidgetSpan(
                      child: descIcon,
                    ),
                    WidgetSpan(
                      child: SizedBox(width: 5),
                    ),
                    //描述文字
                    descText
                  ]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      height: width,
      width: width,
      alignment: Alignment.center,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.loose,
            children: [
              cover,
              //右上角播放次数
              Positioned(
                top: 5.0,
                right: 10.0,
                child: playTimes,
              ),
              //下部描述
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: desc,
              )
            ],
          )),
    );
  }
}
