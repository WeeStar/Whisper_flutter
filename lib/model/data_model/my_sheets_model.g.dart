// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_sheets_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MySheetsModel _$MySheetsModelFromJson(Map<String, dynamic> json) {
  return MySheetsModel(
      (json['mySheets'] as List)
          ?.map((e) =>
              e == null ? null : SheetModel.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['favSheets'] as List)
          ?.map((e) =>
              e == null ? null : SheetModel.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$MySheetsModelToJson(MySheetsModel instance) =>
    <String, dynamic>{
      'mySheets': instance.mySheets?.map((e) => e.toJson())?.toList() ?? null,
      'favSheets': instance.favSheets?.map((e) => e.toJson())?.toList() ?? null,
    };
