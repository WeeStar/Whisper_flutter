import 'package:whisper/model/music_model.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/service/data/config_data_service.dart';
import 'package:whisper/service/http/http_service.dart';

// 业务接口
class ApiService {
  // 获取歌单信息
  static Future<SheetModel> getSheetInfo(MusicSource source, String sheetId,
      {bool showNotice = true}) async {
    var resData = await HttpService.get(
        "music", "sheet_info", source, {"sheet_id": sheetId}, showNotice);
    if (resData == null) {
      return null;
    }
    return SheetModel.fromJson(resData);
  }

  // 搜索歌曲
  static Future<List<MusicModel>> searchMusic(
      MusicSource source, String keyWords,
      [int pageIndex = 1, int pageSize = 30]) async {
    var resData = await HttpService.get("music", "search", source, {
      "key_words": keyWords,
      "page_index": pageIndex.toString(),
      "page_size": pageSize.toString()
    });

    if (resData == null) {
      return List<MusicModel>.empty();
    }

    var musicList = new List<MusicModel>();
    var resList = resData as List<dynamic>;
    for (var item in resList) {
      musicList.add(MusicModel.fromJson(item));
    }
    return musicList;
  }

  // 获取推荐歌单
  static Future<List<RecomModel>> getRecomSheets() async {
    var f1 = getRecomSheetSingle(MusicSource.netease);
    var f2 = getRecomSheetSingle(MusicSource.tencent);
    // var f3 = getRecomSheetSingle(MusicSource.bilibili);
    var f4 = getRecomSheetSingle(MusicSource.migu);
    var f5 = getRecomSheetSingle(MusicSource.kugou);
    // var f6 = getRecomSheetSingle(MusicSource.xiami);
    await ConfigDataService.read();

    var res = await Future.wait<RecomModel>([f1, f2,  f4, f5]);
    var sequence = ConfigDataService.config.musicSourcSeq;

    var resWithSeq = new List<RecomModel>();
    for (var item in sequence) {
      var recom = res.firstWhere((element) => element.source == item,
          orElse: () => null);
      if (recom == null || recom.sheets.length == 0) {
        continue;
      }
      resWithSeq.add(recom);
    }

    return resWithSeq;
  }

  // 获取推荐歌单（单个）
  static Future<RecomModel> getRecomSheetSingle(MusicSource source,
      [int pageIndex = 1, int pageSize = 30]) async {
    //参数构造
    var params = {
      "page_index": pageIndex.toString(),
      "page_size": pageSize.toString()
    };
    //访问接口
    var resData = await HttpService.get("music", "hot_sheets", source, params);
    if (resData == null) {
      return new RecomModel(source, List<SheetModel>.empty());
    }

    var sheetList = new List<SheetModel>();
    var resList = resData as List<dynamic>;
    for (var item in resList) {
      sheetList.add(SheetModel.fromJson(item));
    }
    return new RecomModel(source, sheetList);
  }

  //获取播放信息
  static Future<MusicPlayUrlModel> getPlayInfo(
      MusicSource source, List<String> musicIds) async {
    var body = {"ids": musicIds};

    try {
      var resData = await HttpService.post("music", "music_info", source,
          body: body, showNotice: false);

      //尝试转换类型
      if (resData == null) return MusicPlayUrlModel();
      var resList = resData as List<dynamic>;
      if (resList.isEmpty) return MusicPlayUrlModel();

      //结果构造
      var playUrl = (resList.first["url"] ?? "") as String;
      var imgUrl = (resList.first["img_url"] ?? "") as String;
      return MusicPlayUrlModel(playUrl, imgUrl);
    } catch (Exception) {
      return MusicPlayUrlModel();
    }
  }
}

class RecomModel {
  RecomModel(this.source, this.sheets);
  MusicSource source;
  List<SheetModel> sheets;
}

class MusicPlayUrlModel {
  MusicPlayUrlModel([this.playUrl, this.imgUrl]);
  String playUrl;
  String imgUrl;
}
