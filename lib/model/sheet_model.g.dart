// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SheetModel _$SheetModelFromJson(Map<String, dynamic> json) {
  return SheetModel(
      json['id'] as String,
      json['title'] as String,
      json['description'] as String,
      (json['play'] == null) ? null : json['play'].toString(),
      json['cover_img_url'] as String,
      json['ori_cover_img_url'] as String,
      json['source_url'] as String,
      musicSourceFromString(json['sheet_source'] as String),
      (json['tracks'] as List)
              ?.map((e) => e == null
                  ? null
                  : MusicModel.fromJson(e as Map<String, dynamic>))
              ?.toList() ??
          null,
      (json['is_my'] ?? false) as bool);
}

Map<String, dynamic> _$SheetModelToJson(SheetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'play': instance.play,
      'cover_img_url': instance.cover_img_url,
      'ori_cover_img_url': instance.ori_cover_img_url,
      'source_url': instance.source_url,
      'sheet_source': instance.sheet_source.name,
      'tracks': instance.tracks?.map((e) => e.toJson())?.toList() ?? null,
      'is_my': instance.is_my
    };
