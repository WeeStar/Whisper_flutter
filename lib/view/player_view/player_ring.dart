import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:whisper/service/data/cur_play_data_service.dart';
import 'package:whisper/service/event_service.dart';

//播放器圆形进度
class PlayerRingView extends StatefulWidget {
  @override
  State<PlayerRingView> createState() => new _PlayerRingViewState();
}

class _PlayerRingViewState extends State<PlayerRingView>
    with TickerProviderStateMixin {
  String curMusicImg;
  Duration totalTime;
  Duration curTime;
  AnimationController controller;

  _PlayerRingViewState() {
    var curMusic = CurPlayDataService.curPlay.curMusic;
    curMusicImg = curMusic?.img_url ?? "";
    curTime = Duration.zero;
    totalTime = Duration(minutes: 1);

    //动画控制器
    controller =
        AnimationController(duration: const Duration(seconds: 10), vsync: this);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
        controller.forward();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    //当前音乐变化 监听 改变封面
    eventBus.on<CurMusicRefreshEvent>().listen((event) {
      setState(() {
        curMusicImg = event.music?.img_url ?? "";
        //进度置空
        curTime = Duration.zero;
        totalTime = event.totalTime;

        //重置动画
        controller.reset();
      });
    });

    //当前时长变化 改变进度
    eventBus.on<PlayTimeRefreshEvent>().listen((event) {
      setState(() {
        curTime = event.curTime;
      });
    });

    eventBus.on<PlayStateRefreshEvent>().listen((event) {
      setState(() {
        if (event.state == AudioPlayerState.PLAYING) {
          //动画执行
          controller.forward();
        } else if (event.state == AudioPlayerState.PAUSED ||
            event.state == AudioPlayerState.STOPPED) {
          //动画停止
          controller.stop();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildCover() {
    return ClipOval(
      child: curMusicImg.isEmpty
          ? Image.asset("images/empty.png",
              width: 25,
              height: 25,
              alignment: Alignment.center,
              fit: BoxFit.fill)
          : OctoImage(
              image: CachedNetworkImageProvider(curMusicImg),
              height: 25,
              width: 25,
              placeholderBuilder: (_) {
                return Image.asset("images/empty.png",
                    alignment: Alignment.center, fit: BoxFit.fill);
              },
              errorBuilder: (_, object, stracktrace) {
                return Image.asset("images/empty.png",
                    alignment: Alignment.center, fit: BoxFit.fill);
              },
              fit: BoxFit.cover,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        //环形进度条
        Container(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: totalTime == null
                ? 0.0
                : (curTime?.inMilliseconds ?? 0).toDouble() / totalTime.inMilliseconds,
            backgroundColor: Colors.grey[300].withOpacity(0.6),
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
        RotationTransition(
            //设置动画的旋转中心
            alignment: Alignment.center,
            //动画控制器
            turns: controller,
            //将要执行动画的子view
            child: _buildCover())
      ],
    );
  }
}
