import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

class SheetInfoCoverView extends StatelessWidget {
  final String _coverImg;//封面图片
  final String _title;//歌单标题
  final int _trackNums;

  SheetInfoCoverView(this._coverImg,this._title,this._trackNums);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    //封面图
    var cover = OctoImage(
      image: CachedNetworkImageProvider(_coverImg),
      height: 100,
      width: 100,
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

    //背景
    var backgroundImg = OctoImage(
        image: CachedNetworkImageProvider(_coverImg),
        fit: BoxFit.cover,
        placeholderBuilder: (_) {
          return Image.asset("images/empty.png",
              alignment: Alignment.center, fit: BoxFit.fill);
        },
        errorBuilder: (_, object, stracktrace) {
          return Image.asset("images/empty.png",
              alignment: Alignment.center, fit: BoxFit.fill);
        });

    //标题
    var title = Text(_title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).textTheme.subtitle1.color));

    //描述
    var desc = Text(
      "$_trackNums 首歌曲",
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).textTheme.subtitle1.color),
    );

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: width * 0.70,
      child: Stack(
        fit: StackFit.expand,
        children: [
          //背景
          backgroundImg,

          //上层
          ClipRRect(
              child: BackdropFilter(
                  //模糊背景
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 20),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    decoration: new BoxDecoration(
                        color: Theme.of(context).backgroundColor.withOpacity(0.2)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //封面图
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: cover,
                        ),

                        SizedBox(
                          width: 15,
                        ),

                        //右侧文字
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title,
                              SizedBox(
                                height: 10,
                              ),
                              desc
                            ],
                          ),
                        )
                      ],
                    ),
                  )))
        ],
      ),
    );
  }
}
