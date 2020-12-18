// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cur_play_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurPlayModel _$CurPlayModelFromJson(Map<String, dynamic> json) {
  return CurPlayModel(
      (json['curList'] as List)
          ?.map((e) =>
              e == null ? null : MusicModel.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['curMusic'] == null
          ? null
          : MusicModel.fromJson(json['curMusic'] as Map<String, dynamic>),
      _$enumDecodeNullable(_$RoundModeEnumEnumMap, json['roundMode']));
}

Map<String, dynamic> _$CurPlayModelToJson(CurPlayModel instance) =>
    <String, dynamic>{
      'curList': instance.curList?.map((e) => e.toJson())?.toList() ?? null,
      'curMusic': instance.curMusic?.toJson() ?? null,
      'roundMode': _$RoundModeEnumEnumMap[instance.roundMode]
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$RoundModeEnumEnumMap = <RoundModeEnum, dynamic>{
  RoundModeEnum.listRound: 'listRound',
  RoundModeEnum.randomRound: 'randomRound',
  RoundModeEnum.singleRound: 'singleRound'
};
