import 'package:whisper/model/sheet_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_sheets_model.g.dart';

@JsonSerializable()

/// 我的歌单模型
class MySheetsModel
{
    /// 我的歌单
    var mySheets=<SheetModel>[];
    
    /// 收藏歌单
    var favSheets=<SheetModel>[];
    
    MySheetsModel(this.mySheets, this.favSheets);
    MySheetsModel.empty();

  factory MySheetsModel.fromJson(Map<String, dynamic> json) =>
      _$MySheetsModelFromJson(json);
  Map<String, dynamic> toJson() => _$MySheetsModelToJson(this);
}