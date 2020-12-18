// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicModel _$MusicModelFromJson(Map<String, dynamic> json) {
  return MusicModel(
      json['id'] as String,
      json['title'] as String,
      json['artist'] as String,
      json['artist_id'] as String,
      json['album'] as String,
      json['album_id'] as String,
      musicSourceFromString(json['source'] as String),
      json['source_url'] as String,
      json['url'] as String,
      json['img_url'] as String,
      json['sheet_id'] as String,
      (json['need_vip'] ?? false) as bool,
      (json['has_copyright'] ?? false) as bool);
}

Map<String, dynamic> _$MusicModelToJson(MusicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'artist_id': instance.artist_id,
      'album': instance.album,
      'album_id': instance.album_id,
      'source': instance.source.name,
      'source_url': instance.source_url,
      'url': instance.url,
      'img_url': instance.img_url,
      'sheet_id': instance.sheet_id,
      'need_vip': instance.need_vip,
      'has_copyright': instance.has_copyright
    };
