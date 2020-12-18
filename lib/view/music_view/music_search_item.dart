import 'package:flutter/material.dart';
import 'package:whisper/model/music_model.dart';

///单个音乐 搜索结果
class MusicSearchItemView extends StatelessWidget {
  final MusicModel musicInfo;

  MusicSearchItemView(this.musicInfo);

  @override
  Widget build(BuildContext context) {
    //标题
    var title = Expanded(
      child: Text(musicInfo.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: new TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: (musicInfo.isPlayable()
                  ? Theme.of(context).textTheme.bodyText1.color
                  : Theme.of(context).disabledColor))),
    );

    //失效标记
    var unPlay = Container(
        width: 30,
        height: 16,
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: 4),
        child: Text(
          "失效",
          style: new TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).disabledColor),
        ),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).disabledColor,
              width: 1,
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(3), // 设置四周圆角
        ));

    //来源图标
    var sourceImg = Image.asset(
      "images/icon/${musicInfo.source.name}.png",
      fit: BoxFit.fill,
      width: 14,
      height: 14,
    );

    //描述
    var desc = Expanded(
        child: Text(musicInfo.getDesc(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).disabledColor)));

    return Container(
      alignment: Alignment.center,
      height: 54,
      margin: EdgeInsets.fromLTRB(15, 0, 8, 0),
      child: Row(
        children: [
          //中间描述部分
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //主标题行
                Row(
                  children: [
                    //失效标记
                    if (!musicInfo.isPlayable()) unPlay,
                    //主标题
                    title
                  ],
                ),

                SizedBox(
                  height: 3,
                ),

                //副标题行
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //来源图标
                    sourceImg,
                    SizedBox(
                      width: 5,
                    ),
                    //描述
                    desc,
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
