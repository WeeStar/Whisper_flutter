// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigModel _$ConfigModelFromJson(Map<String, dynamic> json) {
  return ConfigModel(
    json['colorMode'] as int,
    json['isReplaceCurList'] as bool,
    (json['musicSourcSeq'] as List?)
            ?.map((e) => musicSourceFromString(e))
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$ConfigModelToJson(ConfigModel instance) =>
    <String, dynamic>{
      'colorMode': instance.colorMode,
      'isReplaceCurList': instance.isReplaceCurList,
      'musicSourcSeq': instance.musicSourcSeq.map((e) => e.name),
    };
