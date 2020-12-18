import 'package:json_annotation/json_annotation.dart';

part 'music_model.g.dart';

@JsonSerializable()

/// 歌曲模型
class MusicModel {
  /// 歌曲ID
  String id;

  /// 歌曲标题
  String title;

  /// 艺术家名称
  String artist;

  /// 艺术家ID
  String artist_id;

  /// 专辑
  String album;

  /// 专辑ID
  String album_id;

  /// 来源(QQ、网易云等)
  MusicSource source;

  /// 来源url
  String source_url;

  /// url
  String url;

  /// 音乐封面
  String img_url;

  /// 所属歌单ID
  String sheet_id;

  /// 是否需要VIP
  bool need_vip = false;

  /// 是否有版权
  bool has_copyright = true;

  /// 是否可播放
  /// - Returns: 是否可播放
  bool isPlayable() {
    return this.has_copyright && !this.need_vip;
  }

  /// 获取歌曲描述（艺术家 - 专辑）
  /// - Returns: 歌曲描述
  String getDesc() {
    var desc = "";
    if (this.artist == null || this.artist == "") {
      desc = "未知歌手";
    } else {
      desc = this.artist;
    }

    if (this.album == null || this.album == "") {
      desc += " - 未知专辑";
    } else {
      desc += " - " + this.album;
    }
    return desc;
  }

  MusicModel(
      this.id,
      this.title,
      this.artist,
      this.artist_id,
      this.album,
      this.album_id,
      this.source,
      this.source_url,
      this.url,
      this.img_url,
      this.sheet_id,
      this.need_vip,
      this.has_copyright);
  MusicModel.empty();

  factory MusicModel.fromJson(Map<String, dynamic> json) =>
      _$MusicModelFromJson(json);
  Map<String, dynamic> toJson() => _$MusicModelToJson(this);
}

/// 音乐来源枚举
enum MusicSource { unknow, tencent, netease, bilibili, xiami, migu, kugou }

extension MusicSourceExtension on MusicSource {
  String get name => _getName(this);
  String _getName(Object enumEntry) {
    final String description = enumEntry.toString();
    final int indexOfDot = description.indexOf('.');
    assert(indexOfDot != -1 && indexOfDot < description.length - 1);
    return description.substring(indexOfDot + 1);
  }

  String get desc{
    switch (this) {
      case MusicSource.netease:
        return "网易云音乐";
      case MusicSource.tencent:
        return "QQ音乐";
      case MusicSource.bilibili:
        return "Bilibili音乐";
      case MusicSource.xiami:
        return "虾米音乐";
      case MusicSource.migu:
        return "咪咕音乐";
      case MusicSource.kugou:
        return "酷狗音乐";
      default:
        return "未知来源";
    }
  }
}

MusicSource musicSourceFromString(String value) {
  return MusicSource.values.firstWhere(
      (e) => e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
}
