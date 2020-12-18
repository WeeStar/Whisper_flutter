import 'package:flutter/material.dart';
import 'package:whisper/model/music_model.dart';

///单个音乐
class MusicItemView extends StatefulWidget {
  final MusicModel musicInfo;
  final int musicIdx;
  final bool isPlaying;
  final delCallBack;

  MusicItemView(this.musicInfo,
      {Key key,
      this.musicIdx,
      this.isPlaying = false,
      this.delCallBack })
      : super(key: key);

  @override
  _MusicItemViewState createState() => _MusicItemViewState();
}

class _MusicItemViewState extends State<MusicItemView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    //左侧序号
    var idx = Container(
      alignment: Alignment.center,
      width: 32,
      margin: EdgeInsets.only(right: 8),
      child: Text(
        widget.musicIdx.toString(),
        maxLines: 1,
        style: new TextStyle(
            fontSize: widget.musicIdx.toString().length > 2 ? 12 : 16,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).disabledColor),
      ),
    );

    //标题
    var title = Expanded(
      child: Text(widget.musicInfo.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: new TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: widget.isPlaying
                  ? Theme.of(context).primaryColor
                  : (widget.musicInfo.isPlayable()
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
      "images/icon/${widget.musicInfo.source.name}.png",
      fit: BoxFit.fill,
      width: 14,
      height: 14,
    );

    //描述
    var desc = Expanded(
        child: Text(widget.musicInfo.getDesc(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).disabledColor)));

    return Container(
      alignment: Alignment.center,
      height: 54,
      margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        children: [
          idx,
          //中间描述部分
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //主标题行
                Row(
                  children: [
                    //失效标记
                    if (!widget.musicInfo.isPlayable()) unPlay,
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

          //删除标记
          if (widget.delCallBack != null)
            InkWell(
              child: Container(
                alignment: Alignment.center,
                width: 30,
                margin: EdgeInsets.only(left: 5),
                child: Icon(Icons.clear,
                    size: 20, color: Theme.of(context).disabledColor),
              ),
              onTap: () {
                widget.delCallBack();
              },
            )
        ],
      ),
    );
  }
}
