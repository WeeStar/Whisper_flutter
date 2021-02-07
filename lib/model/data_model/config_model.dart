import 'package:whisper/model/music_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'config_model.g.dart';

@JsonSerializable()
class ConfigModel extends Object {
  /// 色彩模式 0自动 1浅色 2深色
  int colorMode = 0;

  /// 是否替换当前列表
  bool isReplaceCurList = true;

  /// 优先级
  var musicSourcSeq = [
    MusicSource.netease,
    MusicSource.tencent,
    MusicSource.migu,
    MusicSource.kugou
  ];

  ConfigModel(this.colorMode, this.isReplaceCurList, this.musicSourcSeq);
  ConfigModel.empty();

  factory ConfigModel.fromJson(Map<String, dynamic> json) => _$ConfigModelFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigModelToJson(this);
}
