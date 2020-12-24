import 'dart:io';
import 'dart:convert';
import 'package:whisper/app_const/app_path.dart';
import 'package:whisper/model/data_model/his_model.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/model/sheet_model.dart';

import '../event_service.dart';

///历史数据读写
class HisDataService {
  static List<String> searchHis;
  static List<SheetModel> playSheetHis;

  ///读取
  static Future<void> read() async {
    if (searchHis != null && playSheetHis != null) {
      return;
    }

    //获取文件内容
    File file = new File(await AppPath.hisPath());
    var jsonStr = await file.readAsString();

    //文件为空 返回空对象
    if (jsonStr == null || jsonStr == "") {
      searchHis = new List<String>();
      playSheetHis = new List<SheetModel>();
    } else {
      Map mySheetsMap = jsonDecode(jsonStr);
      var sheetsData = new HisModel.fromJson(mySheetsMap);
      searchHis = sheetsData.searchHis;
      playSheetHis = sheetsData.playSheetHis;
    }
  }

  ///写入
  static _write() async {
    File file = new File(await AppPath.hisPath());
    var jsonStr = jsonEncode(new HisModel(searchHis, playSheetHis));
    file.writeAsString(jsonStr);
  }

  ///插入搜索历史
  static Future<void> addHis(String keyWord) async {
    if (keyWord == null || keyWord == "") {
      return;
    }

    //深拷贝对象
    await read();
    var newSearchHis = new List<String>();
    newSearchHis.add(keyWord);
    for (var item in searchHis) {
      if (item == keyWord) {
        continue;
      }
      newSearchHis.add(item);
    }

    //对象赋值
    searchHis = newSearchHis;
    await _write();
  }

  ///清空搜索历史
  static clearHis() async {
    await read();

    //对象赋值
    searchHis = new List<String>();
    await _write();
  }

  ///写入歌单历史
  static addSheetHis(SheetModel sheet) async {
    if (sheet == null) {
      return;
    }

    //深拷贝对象
    var newSheet = new SheetModel.fromJson(sheet.toJson());
    newSheet.tracks = List<MusicModel>.empty();

    //加入歌单 先新建变量进行操作
    await read();
    var newSheetHis = new List<SheetModel>();
    newSheetHis.add(sheet);
    for (var item in playSheetHis) {
      if (item.id == sheet.id) {
        continue;
      }
      newSheetHis.add(item);
    }

    //前20个
    if (newSheetHis.length > 20) newSheetHis = newSheetHis.sublist(0, 19);

    //对象赋值
    playSheetHis = newSheetHis;
    await _write();

    eventBus.fire(SheetHisRefreshEvent("add"));
  }

  ///删除歌单播放历史
  static Future<bool> delSheetHis(String sheetId) async {
    //校验
    await read();
    var mySheet = playSheetHis.firstWhere((element) => element.id == sheetId,
        orElse: () => null);
    if (mySheet == null) {
      return true;
    }

    //删除
    playSheetHis.removeWhere((element) => element.id == sheetId);
    await _write();
    return true;
  }
}
