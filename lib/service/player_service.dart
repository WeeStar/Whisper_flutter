import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:whisper/model/data_model/cur_play_model.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/service/data/cur_play_data_service.dart';
import 'package:whisper/service/data/his_data_service.dart';
import 'package:whisper/service/event_service.dart';
import 'package:whisper/service/http/api_service.dart';

// 播放器服务
class PlayerService {
  //当前音频
  static MusicModel curMusic;
  static List<MusicModel> curList;
  static Duration curTime;

  //循环方式
  static RoundModeEnum roundMode;

  //播放器
  static AudioPlayer audioPlayer;

  //平台
  static TargetPlatform platform;

  //监听事件
  static StreamSubscription _onPositionChanged;
  static StreamSubscription _onPlayerStateChanged;
  static StreamSubscription _onPlayError;
  static StreamSubscription _onNotifyStateChanged;
  static StreamSubscription _onPlayerCommand;

  //初始化
  static build(TargetPlatform _platform) {
    platform = _platform;
    curMusic = CurPlayDataService.curPlay.curMusic;
    curList = CurPlayDataService.curPlay.curList;
    roundMode = CurPlayDataService.curPlay.roundMode;
  }

  static dispose() {
    audioPlayer?.release();
    audioPlayer?.dispose();
  }

  //播放
  static Future<void> play({MusicModel music, SheetModel sheet}) async {
    //处理插入当前列表
    //播放整个歌单
    if (sheet != null) {
      //处理无效歌曲
      var playSheet = sheet;
      playSheet.tracks =
          sheet.tracks.where((element) => element.isPlayable()).toList();
      if (playSheet.tracks == null || playSheet.tracks.isEmpty) return;

      //设置当前音乐 当前列表
      curList = playSheet.tracks;
      if (!(music?.isPlayable() ?? false)) music = null;
      curMusic = music ?? curList[0];

      //记录播放历史
      HisDataService.addSheetHis(sheet);
    }

    //播放单首歌曲
    else if (music != null) {
      //播放无效单曲 跳出
      if (!music.isPlayable()) return;

      //需插入当前播放列表 获取插入位置
      if (!curList.any((element) => element.id == music.id)) {
        var curIdx = _getInsertIdx();
        curList.insert(curIdx, music);
      }
      //赋值当前音乐为传入音乐
      curMusic = music;
    }

    //否则为直接恢复播放
    //当前为空 跳出
    if (curMusic == null) return;

    //直接恢复播放的 尝试恢复
    audioPlayer?.setPlaybackRate(playbackRate: 1.0);
    if (music == null && sheet == null && audioPlayer != null) {
      audioPlayer.resume();
      return;
    }

    //初始化播放器 播放当前音乐
    var success = await _initAudioPlayer();
    //初始化失败 跳下一首
    if (!success) {
      if (curList.length > 1) {
        next(true);
      }
      return;
    }

    //播放
    audioPlayer.resume();

    //直接恢复播放的 不在记录本地数据
    if (music == null && sheet == null) return;

    //记录当前播放
    CurPlayDataService.curPlay.curList = curList;
    CurPlayDataService.curPlay.curMusic = curMusic;
    CurPlayDataService.write();
  }

  //暂停
  static pause() {
    audioPlayer?.pause();
    audioPlayer?.setPlaybackRate(playbackRate: 0.0);
  }

  //上一首
  static pre() {
    //列表为空 跳出
    if (curList == null || curList.isEmpty) return;

    //只有一首歌 跳转到0
    if (curList.length == 1) {
      seek(Duration.zero);
      return;
    }

    //获取当前位置 上一曲位置
    var curIdx = _getCurIdx();
    var preIdx = curIdx == 0 ? curList.length - 1 : curIdx - 1;

    //播放
    play(music: curList[preIdx]);
  }

  //下一首
  static next([bool isForce = false]) {
    //列表为空 跳出
    if (curList == null || curList.isEmpty) return;

    //只有一首歌 跳转到0
    if (curList.length == 1) {
      seek(Duration.zero);
      return;
    }

    //获取当前位置 下一曲位置
    var curIdx = _getCurIdx();
    var nextIdx = _getNextIdx(isForce);

    //不变 seek0
    if (curIdx == nextIdx) {
      seek(Duration.zero);
      return;
    }

    //播放
    play(music: curList[nextIdx]);
  }

  //跳转
  static seek(Duration seekTo) {
    audioPlayer.seek(seekTo);
  }

  // 私有 初始化播放器
  static Future<bool> _initAudioPlayer() async {
    if (curMusic == null) return false;

    //获取播放地址
    var playUrl = "";
    try {
      var playInfo =
          await ApiService.getPlayInfo(curMusic.source, [curMusic.id]);
      playUrl = playInfo.playUrl;

      //酷狗的歌曲图片由歌曲播放信息中获取
      if (curMusic.source == MusicSource.kugou)
        curMusic.img_url = playInfo.imgUrl;
    } catch (exp) {
      return false;
    }
    if (playUrl == null || playUrl.isEmpty) return false;

    //释放上个监听
    await _onPositionChanged?.cancel();
    await _onPlayerStateChanged?.cancel();
    await _onPlayError?.cancel();
    await _onNotifyStateChanged?.cancel();
    await _onPlayerCommand?.cancel();

    //释放上个Player
    await audioPlayer?.stop();
    await audioPlayer?.release();

    //初始化Player
    audioPlayer = AudioPlayer();
    try {
      var res = await audioPlayer.setUrl(Uri.encodeFull(playUrl));
      if (res != 1) return false;
    } catch (exp) {
      print(exp);
      return false;
    }
    await audioPlayer.setPlaybackRate(playbackRate: 0.0);

    //获取时长
    curTime = Duration.zero;
    var duration = Duration(milliseconds: await audioPlayer.getDuration());

    // 设置IOS锁屏
    if (platform == TargetPlatform.iOS)
      await audioPlayer.setNotification(
          title: curMusic?.title ?? "未知歌曲",
          artist: curMusic?.artist ?? "未知歌手",
          albumTitle: curMusic?.album ?? "未知专辑",
          imageUrl: '',
          duration: duration,
          elapsedTime: Duration(seconds: 0),
          hasNextTrack: true,
          hasPreviousTrack: true);

    //广播当前播放歌曲
    eventBus.fire(CurMusicRefreshEvent(curMusic, duration));

    //当前进度获取 发广播
    _onPositionChanged =
        audioPlayer.onAudioPositionChanged.listen((Duration c) {
      //广播进度
      curTime = c;
      eventBus.fire(PlayTimeRefreshEvent(c));
    });

    //播放状态变化 发广播
    _onPlayerStateChanged = audioPlayer.onPlayerStateChanged.listen((state) {
      //播放完成 下一首
      if (state == AudioPlayerState.COMPLETED) {
        print("播放完成");
        next();
      }

      print("状态变化广播");

      //调整进度条速率
      audioPlayer?.setPlaybackRate(
          playbackRate: state == AudioPlayerState.PLAYING ? 1.0 : 0.0);

      //广播播放状态
      eventBus.fire(PlayStateRefreshEvent(state));
    });

    //播放失败 下一首
    _onPlayError = audioPlayer.onPlayerError.listen((event) {
      next(true);
      print("播放失败");
    });

    //ios 锁屏通知发起状态变化 接收播放暂停
    _onNotifyStateChanged =
        audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      print("锁屏播放暂停");

      //调整进度条速率
      audioPlayer?.setPlaybackRate(
          playbackRate: state == AudioPlayerState.PLAYING ? 1.0 : 0.0);

      //广播播放状态
      eventBus.fire(PlayStateRefreshEvent(state));
    });

    //接收远端操作 耳机线控 锁屏按钮等 接收上一曲 下一曲
    _onPlayerCommand =
        audioPlayer.onPlayerCommand.listen((PlayerControlCommand event) {
      if (event == PlayerControlCommand.NEXT_TRACK) {
        next(true);
      } else if (event == PlayerControlCommand.PREVIOUS_TRACK) {
        pre();
      }
      print("锁屏上下曲");
    });
    return true;
  }

  //私有 获取当前播放位置
  static int _getCurIdx() {
    if (curMusic == null || curList == null || curList.isEmpty) return 0;

    if (!curList.any((element) => element.id == curMusic.id)) return 0;

    return curList.indexWhere((element) => element.id == curMusic.id);
  }

  //私有 获取插入位置
  static int _getInsertIdx() {
    if (curMusic == null || curList == null || curList.isEmpty) return 0;
    return _getCurIdx() + 1;
  }

  //私有 获取下首位置
  static int _getNextIdx([bool isForce = false]) {
    var curIdx = _getCurIdx();

    //强制下一首
    if (isForce) return ((curIdx == (curList.length - 1)) ? 0 : curIdx + 1);

    switch (roundMode) {
      case RoundModeEnum.listRound:
        return ((curIdx == (curList.length - 1)) ? 0 : curIdx + 1);
      case RoundModeEnum.randomRound:
        var nextIdx = 0;
        var random = new Random();
        do {
          nextIdx = random.nextInt(curList.length);
        } while (nextIdx == curIdx);
        return nextIdx;
      case RoundModeEnum.singleRound:
        return curIdx;
      default:
        return -1;
    }
  }
}
