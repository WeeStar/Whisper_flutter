import 'dart:io';
import 'dart:convert';
import 'package:whisper/app_const/app_path.dart';
import 'package:whisper/model/data_model/my_sheets_model.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:whisper/service/data/his_data_service.dart';

import '../event_service.dart';

///我的歌单配置读写
class MySheetsDataService {
  static List<SheetModel>? mySheets;
  static List<SheetModel>? favSheets;

  ///读取
  static Future<void> read() async {
    if (mySheets != null && favSheets != null) {
      return;
    }

    //获取文件内容
    File file = new File(await AppPath.mySheetsPath());
    var jsonStr = await file.readAsString();

    //文件为空 返回空对象
    if (jsonStr == "") {
      mySheets = <SheetModel>[];
      favSheets = <SheetModel>[];
    } else {
      Map<String, dynamic> mySheetsMap = jsonDecode(jsonStr);
      var sheetsData = new MySheetsModel.fromJson(mySheetsMap);
      mySheets = sheetsData.mySheets;
      favSheets = sheetsData.favSheets;
    }
  }

  ///写入
  static _write() async {
    File file = new File(await AppPath.mySheetsPath());
    var jsonStr = jsonEncode(new MySheetsModel(mySheets!, favSheets!));
    file.writeAsString(jsonStr);
  }

  ///添加我的歌单
  static Future<SheetModel?> addMySheet(SheetModel inSheet) async {
    if (inSheet.id == null) return null;

    //深copy歌单
    var sheet = SheetModel.fromJson(inSheet.toJson());
    sheet.is_my = true;

    //检查相同歌单
    await read();
    var mySheet = mySheets!.firstWhere((element) => element.id == sheet.id,
        orElse: () => SheetModel.empty());

    if (mySheet.id == null) {
      //不存在相同歌单 直接新增
      mySheets!.insert(0, sheet);
      await _write();
      eventBus.fire(MySheetsRefreshEvent("add"));
      return sheet;
    } else {
      //存在相同歌单 歌曲merge
      for (var myMusic in sheet.tracks) {
        if (!mySheet.tracks.any((element) => element.id == myMusic.id)) {
          mySheet.tracks.insert(0, myMusic);
        }
      }
      await _write();
      eventBus.fire(MySheetsRefreshEvent("add"));
      return mySheet;
    }
  }

  ///更新我的歌单
  static Future<bool> updateMySheet(SheetModel sheet) async {
    if (sheet.id == null) return false;

    //校验
    await read();
    var mySheet = mySheets!.firstWhere((element) => element.id == sheet.id,
        orElse: () => SheetModel.empty());
    if (mySheet.id == null) {
      return false;
    }

    //更新歌单
    mySheet.title = sheet.title;
    mySheet.description = sheet.description;
    mySheet.cover_img_url = sheet.cover_img_url;
    mySheet.ori_cover_img_url = sheet.ori_cover_img_url;

    //保存数据
    await _write();
    eventBus.fire(MySheetsRefreshEvent("update"));
    return true;
  }

  ///删除我的歌单
  static Future<bool> delMySheet(String sheetId) async {
    //校验
    await read();
    var mySheet = mySheets!.firstWhere((element) => element.id == sheetId,
        orElse: () => SheetModel.empty());
    if (mySheet.id == null) {
      return true;
    }

    mySheets!.removeWhere((element) => element.id == sheetId);

    //同时删除最近播放 避免问题
    await HisDataService.delSheetHis(sheetId);

    //保存数0
    await _write();
    eventBus.fire(MySheetsRefreshEvent("del"));
    return true;
  }

  ///我的歌单插入歌曲
  static Future<bool> insertMusicMySheet(
      String sheetId, MusicModel music) async {
    if (music.id == null) {
      return false;
    }

    //校验
    await read();
    var mySheet = mySheets!.firstWhere((element) => element.id == sheetId,
        orElse: () => SheetModel.empty());
    if (mySheet.id == null) {
      return false;
    }
    if (mySheet.tracks.any((element) => element.id == music.id)) {
      return true;
    }

    //插入
    mySheet.tracks.insert(0, music);

    //保存数据
    await _write();
    return true;
  }

  ///判断歌曲存在
  static Future<bool> existMusicMySheet(String sheetId, String musicId) async {
    var mySheet = mySheets!.firstWhere((element) => element.id == sheetId,
        orElse: () => SheetModel.empty());
    if (mySheet.id == null) {
      return false;
    }
    return mySheet.tracks.any((element) => element.id == musicId);
  }

  ///我的歌单删除歌曲
  static Future<bool> delMusicMySheet(String sheetId, String musicId) async {
    //校验
    await read();
    var mySheet = mySheets!.firstWhere((element) => element.id == sheetId,
        orElse: () => SheetModel.empty());
    if (mySheet.id == null) {
      return false;
    }
    if (!mySheet.tracks.any((element) => element.id == musicId)) {
      return true;
    }

    //插入
    mySheet.tracks.removeWhere((element) => element.id == musicId);

    //保存数据
    await _write();
    return true;
  }

  ///添加收藏歌单
  static Future<void> addFavSheet(SheetModel inSheet) async {
    if (inSheet.id == null) {
      return;
    }

    //深copy歌单
    var sheet = SheetModel.fromJson(inSheet.toJson());
    sheet.tracks = List<MusicModel>.empty();

    //检查相同歌单
    await read();
    var favSheet = favSheets!.firstWhere((element) => element.id == sheet.id,
        orElse: () => SheetModel.empty());

    if (favSheet.id == null) {
      //不存在相同歌单 直接新增
      favSheets!.insert(0, sheet);
    } else {
      //存在相同歌单 更新信息
      favSheet = sheet;
    }

    //保存数据
    await _write();
  }

  ///删除收藏歌单
  static Future<bool> delFavSheet(String sheetId) async {
    //检查相同歌单
    await read();
    if (!favSheets!.any((element) => element.id == sheetId)) {
      return true;
    }

    //删除
    favSheets!.removeWhere((element) => element.id == sheetId);

    //保存数据
    await _write();
    return true;
  }

  ///是否收藏歌单
  static Future<bool> isFavSheets(String sheetId) async {
    await read();
    return favSheets!.any((element) => element.id == sheetId);
  }
}
