import 'package:whisper/model/music_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cur_play_model.g.dart';

@JsonSerializable()
class CurPlayModel {
  /// 当前音乐列表
  var curList = List<MusicModel>();

  /// 当前音乐
  MusicModel curMusic;

  /// 循环模式
  var roundMode = RoundModeEnum.listRound;

  CurPlayModel(this.curList, this.curMusic, this.roundMode);
  CurPlayModel.empty();

  factory CurPlayModel.fromJson(Map<String, dynamic> json) =>
      _$CurPlayModelFromJson(json);
  Map<String, dynamic> toJson() => _$CurPlayModelToJson(this);
}

/// 循环类型枚举
enum RoundModeEnum { listRound, randomRound, singleRound }
