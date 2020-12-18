// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'his_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HisModel _$HisModelFromJson(Map<String, dynamic> json) {
  return HisModel(
      (json['searchHis'] as List)?.map((e) => e as String)?.toList() ?? null,
      (json['playSheetHis'] as List)
              ?.map((e) => e == null
                  ? null
                  : SheetModel.fromJson(e as Map<String, dynamic>))
              ?.toList() ??
          null);
}

Map<String, dynamic> _$HisModelToJson(HisModel instance) => <String, dynamic>{
      'searchHis': instance.searchHis,
      'playSheetHis': instance.playSheetHis?.map((e) => e.toJson())?.toList() ?? null,
    };
