import 'package:audioplayers/audioplayers.dart';
import 'package:event_bus/event_bus.dart';
import 'package:whisper/model/music_model.dart';

//初始化Bus
EventBus eventBus = EventBus();

//配置文件刷新
class ConfigRefreshEvent {
  String string;
  ConfigRefreshEvent(this.string);
}

//我的歌单刷新
class MySheetsRefreshEvent {
  String string;
  MySheetsRefreshEvent(this.string);
}

//歌单历史刷新
class SheetHisRefreshEvent {
  String string;
  SheetHisRefreshEvent(this.string);
}

//当前播放刷新
class CurMusicRefreshEvent {
  MusicModel music;
  Duration totalTime;
  CurMusicRefreshEvent(this.music, this.totalTime);
}

//播放时长刷新
class PlayTimeRefreshEvent {
  Duration curTime;

  PlayTimeRefreshEvent(this.curTime);
}

//播放状态刷新
class PlayStateRefreshEvent {
  AudioPlayerState state;

  PlayStateRefreshEvent(this.state);
}
