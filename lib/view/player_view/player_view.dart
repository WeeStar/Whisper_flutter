import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:whisper/app_const/app_color.dart';
import 'package:whisper/model/data_model/cur_play_model.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/service/data/cur_play_data_service.dart';
import 'package:whisper/service/event_service.dart';
import 'package:whisper/service/play/curlist_service.dart';
import 'package:whisper/service/play/player_service.dart';
import 'package:whisper/view/player_view/player_bottom_sheet.dart';

//播放页
class PlayerView extends StatefulWidget {
  @override
  State<PlayerView> createState() => new _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> with TickerProviderStateMixin {
  MusicModel curMusic;
  RoundModeEnum roundMode;

  String curMusicId;
  String curMusicImg;

  Duration totalTime;
  Duration curTime;
  bool isPlaying;

  double width;

  _PlayerViewState() {
    curMusic = PlayerService.curMusic;
    roundMode = CurListService.roundMode;

    curMusicId = curMusic?.id ?? "";
    curMusicImg = curMusic?.img_url ?? "";

    curTime = PlayerService.curTime;
    totalTime = PlayerService.totalTime;
    isPlaying = PlayerService.isPlaying;
  }

  @override
  void initState() {
    super.initState();

    //当前音乐变化 监听 改变封面
    eventBus.on<CurMusicRefreshEvent>().listen((event) {
      setState(() {
        curMusic = event.music;
        curMusicId = curMusic?.id ?? "";
        curMusicImg = event.music?.img_url ?? "";
        //进度置空
        print("212");
        curTime = Duration.zero;
        totalTime = event.totalTime;
      });
    });

    //当前时长变化 改变进度
    eventBus.on<PlayTimeRefreshEvent>().listen((event) {
      setState(() {
        curTime = event.curTime;
      });
    });

    //播放状态变化
    eventBus.on<PlayStateRefreshEvent>().listen((event) {
      setState(() {
        isPlaying = event.state == AudioPlayerState.PLAYING;
      });
    });
  }

  //返回栏
  Widget _buildBackBar(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 10,
          ),
          InkWell(
            child: Container(
              alignment: Alignment.center,
              height: 30,
              width: 30,
              child: Icon(Icons.arrow_back_ios,
                  size: 25, color: Theme.of(context).textTheme.bodyText1.color),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  //封面
  Widget _buildCover(BuildContext context) {
    //封面图
    var cover = curMusicImg.isEmpty
        ? Image.asset("images/empty.png",
            width: width * 0.8,
            height: width * 0.8,
            alignment: Alignment.center,
            fit: BoxFit.fill)
        : OctoImage(
            image: CachedNetworkImageProvider(curMusicImg),
            height: width * 0.8,
            width: width * 0.8,
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

    //裁切
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: cover,
    );
  }

  //进度条
  Widget _buildProgress(BuildContext context) {
    //进度条
    var progBar = new SizedBox(
      //限制进度条的高度
      height: 2.0,
      //限制进度条的宽度
      width: width * 0.85,
      child: new LinearProgressIndicator(
          value: (totalTime == null || totalTime.inMilliseconds == 0)
              ? 0.0
              : (curTime?.inMilliseconds ?? 0).toDouble() /
                  totalTime.inMilliseconds,
          //背景颜色
          backgroundColor: AppColor.prgBarBackColor,
          //进度颜色
          valueColor:
              new AlwaysStoppedAnimation<Color>(AppColor.prgBarForeColor)),
    );

    //时长
    var progNum = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(curTime.toString().substring(2, 7),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyText2.color)),
        Text(totalTime.toString().substring(2, 7),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyText2.color)),
      ],
    );

    return Container(
      width: width * 0.85,
      child: Column(
        children: [
          progBar,
          SizedBox(
            height: 5,
          ),
          progNum
        ],
      ),
    );
  }

  //标题
  Widget _buildTitle(BuildContext context) {
    return Text(curMusic.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyText1.color));
  }

  //副标题
  Widget _buildSubTitle(BuildContext context) {
    return Text(curMusic.getDesc(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).textTheme.bodyText2.color));
  }

  //按钮
  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        //循环方式
        InkWell(
          child: Container(
            alignment: Alignment.center,
            height: width * 0.1,
            width: width * 0.1,
            child: Icon(
                roundMode == RoundModeEnum.listRound
                    ? Icons.repeat
                    : roundMode == RoundModeEnum.singleRound
                        ? Icons.repeat_one
                        : Icons.shuffle,
                size: width * 0.1,
                color: Theme.of(context).textTheme.bodyText1.color),
          ),
          onTap: () {
            if (roundMode == RoundModeEnum.listRound) {
              CurPlayDataService.curPlay.roundMode = RoundModeEnum.singleRound;
            } else if (roundMode == RoundModeEnum.singleRound) {
              CurPlayDataService.curPlay.roundMode = RoundModeEnum.randomRound;
            } else if (roundMode == RoundModeEnum.randomRound) {
              CurPlayDataService.curPlay.roundMode = RoundModeEnum.listRound;
            }
            //保存循环方式配置
            CurPlayDataService.write();
            //设置页面与播放器循环方式
            setState(() {
              roundMode = CurPlayDataService.curPlay.roundMode;
            });
            CurListService.setRoundMode();
          },
        ),
        //上一曲
        InkWell(
          child: Container(
            alignment: Alignment.center,
            height: width * 0.12,
            width: width * 0.12,
            child: Icon(Icons.skip_previous,
                size: width * 0.12,
                color: Theme.of(context).textTheme.bodyText1.color),
          ),
          onTap: () {
            PlayerService.pre();
          },
        ),
        //播放暂停
        InkWell(
          child: Container(
            alignment: Alignment.center,
            height: width * 0.18,
            width: width * 0.18,
            child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                size: width * 0.18,
                color: Theme.of(context).textTheme.bodyText1.color),
          ),
          onTap: () {
            if (isPlaying)
              PlayerService.pause();
            else
              PlayerService.play();
          },
        ),
        //下一曲
        InkWell(
          child: Container(
            alignment: Alignment.center,
            height: width * 0.12,
            width: width * 0.12,
            child: Icon(Icons.skip_next,
                size: width * 0.12,
                color: Theme.of(context).textTheme.bodyText1.color),
          ),
          onTap: () {
            PlayerService.next(true);
          },
        ),
        //播放列表
        InkWell(
          child: Container(
            alignment: Alignment.center,
            height: width * 0.1,
            width: width * 0.1,
            margin: EdgeInsets.only(left: 5),
            child: Icon(Icons.queue_music,
                size: width * 0.1,
                color: Theme.of(context).textTheme.bodyText1.color),
          ),
          onTap: () {
            showModalBottomSheet(
              elevation: 20,
              context: context,
              builder: (BuildContext context) {
                return PlayerBottomSheet();
              },
            ).then((val) {
              print(val);
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //返回
        Column(
          children: [
            SizedBox(
              height: 15,
            ),
            _buildBackBar(context),
          ],
        ),

        //封面
        _buildCover(context),

        //进度
        _buildProgress(context),

        //标题 副标题
        SizedBox(
          child: Padding(
              child: Column(
                children: [
                  _buildTitle(context),
                  SizedBox(
                    height: 10,
                  ),
                  _buildSubTitle(context),
                ],
              ),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
          height: 70,
        ),

        //按钮
        Column(
          children: [
            _buildButtons(context),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ],
    ));
  }
}
