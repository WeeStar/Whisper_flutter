import 'package:whisper/model/sheet_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'his_model.g.dart';

@JsonSerializable()

/// 历史模型
class HisModel {
  /// 搜索历史
  var searchHis = <String>[];

  /// 歌单播放历史
  var playSheetHis = <SheetModel>[];

  HisModel(this.searchHis, this.playSheetHis);
  HisModel.empty();

  factory HisModel.fromJson(Map<String, dynamic> json) =>
      _$HisModelFromJson(json);
  Map<String, dynamic> toJson() => _$HisModelToJson(this);
}
