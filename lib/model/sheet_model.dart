import 'package:whisper/model/music_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sheet_model.g.dart';

@JsonSerializable()
class SheetModel {
  /// 歌单ID
  String id;

  /// 歌单标题
  String title;

  /// 歌单描述
  String description;

  /// 播放次数
  String play;

  /// 歌单封面
  String cover_img_url;
  String ori_cover_img_url;

  /// 歌单来源url
  String source_url;
  MusicSource sheet_source;

  /// 歌曲列表
  var tracks = <MusicModel>[];

  /// 是否我的
  bool is_my = false;

  SheetModel(
      this.id,
      this.title,
      this.description,
      this.play,
      this.cover_img_url,
      this.ori_cover_img_url,
      this.source_url,
      this.sheet_source,
      this.tracks,
      this.is_my);
  SheetModel.empty();

  factory SheetModel.fromJson(Map<String, dynamic> json) =>
      _$SheetModelFromJson(json);
  Map<String, dynamic> toJson() => _$SheetModelToJson(this);
}
