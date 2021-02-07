import 'package:flutter/material.dart';
import 'package:whisper/model/data_model/cur_play_model.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/service/event_service.dart';
import 'package:whisper/service/play/curlist_service.dart';
import 'package:whisper/service/play/player_service.dart';
import 'package:whisper/view/music_view/music_item_view.dart';

class PlayerBottomSheet extends StatefulWidget {
  @override
  State<PlayerBottomSheet> createState() => new _PlayerBottomSheetState();
}

class _PlayerBottomSheetState extends State<PlayerBottomSheet>
    with TickerProviderStateMixin {
  List<MusicModel> curList;
  RoundModeEnum roundMode;
  String curMusicId;
  ScrollController _scrollController;

  _PlayerBottomSheetState() {
    curList = CurListService.curList;
    roundMode = CurListService.roundMode;
    var curMusic = CurListService.curMusic;
    curMusicId = curMusic?.id ?? "";
  }

  @override
  void initState() {
    super.initState();

    //当前音乐变化 监听 改变封面
    eventBus.on<CurMusicRefreshEvent>().listen((event) {
      setState(() {
        var curMusic = event.music;
        curMusicId = curMusic?.id ?? "";
      });
    });
  }

  //构造歌单列表
  Widget _buildList(double totalHeight) {
    //计算初始滚动位置
    var offset = 0.0;
    if (curList.length <= 4) {
      //不够4个 不滚动
      offset = 0;
    } else {
      var curIdx = curList.indexWhere((element) => element.id == curMusicId);
      curIdx = curIdx < 0 ? 0 : curIdx;

      if (curIdx <= curList.length - 5) {
        //倒数前4之前 正常滚动
        offset = curIdx * 54.0;
      } else {
        //倒数前4之后 滚动所有
        offset = (curList.length * 54.0 + 48) - totalHeight;
      }
    }

    _scrollController = ScrollController(initialScrollOffset: offset);

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, idx) {
        if (idx == 0) {
          return SizedBox(
            height: 50,
          );
        }
        return InkWell(
            child: MusicItemView(
              curList[idx - 1],
              musicIdx: idx,
              isPlaying: curList[idx - 1].id == curMusicId,
            ),
            onTap: () {
              //无效歌曲跳出
              if (!curList[idx - 1].isPlayable()) return;
              //播放选中歌曲
              PlayerService.play(music: curList[idx - 1]);
            });
      },
      itemCount: curList.length + 1,
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
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
            Text("当前播放",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyText1.color)),
            Text("(" + curList.length.toString() + ")",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyText2.color))
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalHeight = MediaQuery.of(context).size.height * 0.5;

    return Stack(children: <Widget>[
      //背景头部
      Container(
        height: 25,
        width: double.infinity,
        color: Colors.black54,
      ),

      //歌单列表部分
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        height: totalHeight,
        child: _buildList(totalHeight),
      ),

      //头部
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        width: double.infinity,
        height: 48,
        child: _buildHeader(),
      )
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
