import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/service/data/cur_play_data_service.dart';
import 'package:whisper/service/play/curlist_service.dart';
import 'package:whisper/service/event_service.dart';
import 'package:whisper/service/http/api_service.dart';

// 播放器服务
class PlayerService {
  //当前音频
  static MusicModel curMusic;
  static Duration curTime = Duration.zero;
  static Duration totalTime = Duration.zero;

  //播放器
  static AudioPlayer audioPlayer;
  static bool isPlaying = false;
  static bool isLoading = false;
  static Timer _timer;

  //平台
  static TargetPlatform platform;

  //监听事件
  static StreamSubscription _onPositionChanged;
  static StreamSubscription _onPlayerStateChanged;
  static StreamSubscription _onPlayError;
  static StreamSubscription _onNotifyStateChanged;
  static StreamSubscription _onPlayerCommand;

  //初始化
  static build(TargetPlatform _platform) async {
    platform = _platform;
    curMusic = CurPlayDataService.curPlay.curMusic;
  }

  //释放
  static dispose() {
    audioPlayer?.release();
    audioPlayer?.dispose();
  }

  //播放
  static Future<void> play({MusicModel music, SheetModel sheet}) async {
    //直接恢复播放的 尝试恢复
    if (music == null && sheet == null && audioPlayer != null) {
      await audioPlayer.resume();
      return;
    }

    //开关阻塞
    if (isLoading) return;
    audioPlayer?.pause();
    _timer?.cancel();

    //获取要播放的音乐
    var playMusic = CurListService.play(music: music, sheet: sheet);
    if (playMusic == null) return;

    //播放
    _playService(playMusic);
  }

  //暂停
  static pause() {
    audioPlayer?.pause();
  }

  //上一首
  static pre() {
    //开关阻塞
    if (isLoading) return;
    audioPlayer?.pause();
    _timer?.cancel();

    //获取要播放的音乐
    var playMusic = CurListService.pre();
    if (playMusic == null) return;

    //播放
    _playService(playMusic);
  }

  //下一首
  static next([bool isForce = false]) {
    //开关阻塞
    if (isLoading) return;
    audioPlayer?.pause();
    _timer?.cancel();

    //获取要播放的音乐
    var playMusic = CurListService.next();
    if (playMusic == null) return;

    //播放
    _playService(playMusic);
  }

  //删除当前播放歌单中的音乐
  static del(String id) {
    var res = CurListService.del(id);
    if (!res) return;

    //若删除的为当前正在播放的 下一首
    if(id == CurListService.curMusic.id){
      next(true);
    }
  }

  //跳转
  static Future<void> seek(Duration seekTo) async {
    await audioPlayer.seek(seekTo);
  }

  // 私有 播放服务
  static Future<void> _playService(MusicModel playMusic) async {
    //重复播放当前歌曲 跳转到0:00 重新播放
    if (playMusic.id == curMusic.id && audioPlayer != null) {
      await seek(Duration.zero);
      await audioPlayer.resume();
      return;
    }

    //非重复 对curMusic赋值
    curMusic = playMusic;

    _timer = Timer(Duration(milliseconds: 400), () async {
      isLoading = true;

      //释放旧播放器
      await _releasePlayer();

      try {
        //获取播放地址
        var playUrl = await _getPlayUrl(playMusic);
        if (playUrl == "") throw Exception("地址获取失败");

        //初始化播放器
        var initRes = await _initPlayer(playUrl);
        if (!initRes) throw Exception("初始化播放器失败");

        //绑定播放器事件
        _bindPlayerEvent();

        //播放
        await audioPlayer.resume();
        isLoading = false;
      } catch (exp) {
        //初始化失败 跳下一首
        print(exp);
        isLoading = false;
        _errNext();
      }
    });
  }

  // 私有 初始化播放器
  static Future<bool> _initPlayer(String playUrl) async {
    //初始化Player
    audioPlayer = AudioPlayer();
    try {
      var res = await audioPlayer.setUrl(Uri.encodeFull(playUrl));
      if (res != 1) return false;
    } catch (exp) {
      return false;
    }
    await audioPlayer.setReleaseMode(ReleaseMode.STOP);
    await audioPlayer.setPlaybackRate(playbackRate: 0.0);

    //获取时长
    curTime = Duration.zero;
    totalTime = Duration(milliseconds: await audioPlayer.getDuration());

    //广播时长
    eventBus.fire(CurMusicRefreshEvent(curMusic, totalTime));

    // 设置IOS锁屏
    if (platform == TargetPlatform.iOS)
      await audioPlayer.setNotification(
          title: curMusic?.title ?? "未知歌曲",
          artist: curMusic?.artist ?? "未知歌手",
          albumTitle: curMusic?.album ?? "未知专辑",
          imageUrl: '',
          duration: totalTime,
          elapsedTime: Duration(seconds: 0),
          hasNextTrack: true,
          hasPreviousTrack: true);
    return true;
  }

  // 私有 获取播放地址
  static Future<String> _getPlayUrl(MusicModel playMusic) async {
    //获取播放地址
    var playUrl = "";
    var playInfo =
        await ApiService.getPlayInfo(playMusic.source, [playMusic.id]);
    playUrl = playInfo.playUrl;

    //酷狗的歌曲图片由歌曲播放信息中获取
    if (playMusic.source == MusicSource.kugou)
      playMusic.img_url = playInfo.imgUrl;

    return playUrl;
  }

  // 私有 释放播放器
  static Future<void> _releasePlayer() async {
    //释放上个监听
    await _onPositionChanged?.cancel();
    await _onPlayerStateChanged?.cancel();
    await _onPlayError?.cancel();
    await _onNotifyStateChanged?.cancel();
    await _onPlayerCommand?.cancel();

    //释放上个Player
    await audioPlayer?.stop();
    await audioPlayer?.release();
  }

  // 私有 绑定播放器事件
  static void _bindPlayerEvent() {
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
        next();
      }

      isPlaying = state == AudioPlayerState.PLAYING;
      //调整进度条速率
      audioPlayer?.setPlaybackRate(
          playbackRate: state == AudioPlayerState.PLAYING ? 1.0 : 0.0);
      //广播播放状态
      eventBus.fire(PlayStateRefreshEvent(state));
    });

    //播放失败 下一首
    _onPlayError = audioPlayer.onPlayerError.listen((event) {
      next(true);
    });

    //ios 锁屏通知发起状态变化 接收播放暂停
    _onNotifyStateChanged =
        audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      isPlaying = state == AudioPlayerState.PLAYING;
      //调整进度条速率
      audioPlayer.setPlaybackRate(
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
    });
  }

  // 私有 失败下一首
  static Future<void> _errNext() async {
    if (CurListService.curList.length <= 1) return;
    await next(true);
  }
}
