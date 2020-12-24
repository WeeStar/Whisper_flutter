import 'dart:math';

import 'package:whisper/model/data_model/cur_play_model.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/service/data/cur_play_data_service.dart';
import 'package:whisper/service/data/his_data_service.dart';
import 'package:whisper/service/event_service.dart';

// 当前列表服务
// 用于获取上下曲
class CurListService {
  //当前音频
  static MusicModel curMusic;
  static List<MusicModel> curList;
  //循环方式
  static RoundModeEnum roundMode;

  //初始化
  static build() {
    curMusic = CurPlayDataService.curPlay.curMusic;
    curList = CurPlayDataService.curPlay.curList;
    roundMode = CurPlayDataService.curPlay.roundMode;
  }

  //播放
  static MusicModel play({MusicModel music, SheetModel sheet}) {
    MusicModel playMusic; //要播放音乐

    //播放整个歌单
    if (sheet != null) {
      //处理无效歌曲
      var playList =
          sheet.tracks.where((element) => element.isPlayable()).toList();
      if (playList == null || playList.isEmpty) return null;

      //设置要播放音乐 当前列表
      curList = playList;
      if (!(music?.isPlayable() ?? false)) music = null;
      playMusic = music ?? curList[0];

      //记录播放历史
      HisDataService.addSheetHis(sheet);
    }

    //播放单首歌曲
    else if (music != null) {
      //播放无效单曲 跳出
      if (!music.isPlayable()) return null;
      playMusic = music;

      //需插入当前播放列表 获取插入位置
      if (!curList.any((element) => element.id == music.id)) {
        var curIdx = _getInsertIdx();
        curList.insert(curIdx, music);
      }
    }

    //恢复播放
    else {
      playMusic = curMusic;
    }

    //要播放为空 跳出
    if (playMusic == null) return null;

    //更新当前音乐
    _refreshCurMusic(playMusic);
    return playMusic;
  }

  //上一首
  static MusicModel pre() {
    //列表为空 跳出
    if (curList == null || curList.isEmpty) return null;

    //获取当前位置 上一曲位置
    var curIdx = _getCurIdx();
    var preIdx = curIdx == 0 ? curList.length - 1 : curIdx - 1;
    var playMusic = curList[preIdx];

    //更新当前音乐
    _refreshCurMusic(playMusic);
    return playMusic;
  }

  //下一首
  static MusicModel next([bool isForce = false]) {
    //列表为空 跳出
    if (curList == null || curList.isEmpty) return null;

    //获取当前位置 下一曲位置
    var nextIdx = _getNextIdx(isForce);
    var playMusic = curList[nextIdx];

    //更新当前音乐
    _refreshCurMusic(playMusic);
    return playMusic;
  }

  //设置循环方式
  static void setRoundMode() {
    roundMode = CurPlayDataService.curPlay.roundMode;
  }

  //私有 更新当前音乐
  static void _refreshCurMusic(MusicModel playMusic) {
    if (playMusic.id == curMusic.id) return; //重复歌曲 跳出
    curMusic = playMusic;

    //广播当前音乐更新
    eventBus.fire(CurMusicRefreshEvent(curMusic, Duration.zero));

    //记录当前播放数据
    CurPlayDataService.curPlay.curList = curList;
    CurPlayDataService.curPlay.curMusic = curMusic;
    CurPlayDataService.write();
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
      case RoundModeEnum.listRound: //列表循环
        return ((curIdx == (curList.length - 1)) ? 0 : curIdx + 1);
      case RoundModeEnum.randomRound: //随机循环
        var nextIdx = 0;
        if (curList.length == 1) return nextIdx;
        var random = new Random();
        do {
          nextIdx = random.nextInt(curList.length);
        } while (nextIdx == curIdx);
        return nextIdx;
      case RoundModeEnum.singleRound: //单曲循环
        return curIdx;
      default:
        return -1;
    }
  }
}
