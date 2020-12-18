import 'dart:io';
import 'dart:convert';
import 'package:whisper/app_const/app_path.dart';
import 'package:whisper/model/data_model/cur_play_model.dart';

///当前播放读写
class CurPlayDataService {
  static CurPlayModel curPlay;

  ///读取
  static Future<CurPlayModel> read() async {
    if (curPlay != null) {
      return curPlay;
    }

    //获取文件内容
    File file = new File(await AppPath.curPlayPath());
    var jsonStr = await file.readAsString();

    //文件为空 返回空对象
    if (jsonStr == null || jsonStr == "") {
      curPlay = new CurPlayModel.empty();
    } else {
      Map configMap = jsonDecode(jsonStr);
      curPlay = new CurPlayModel.fromJson(configMap);

      //当前歌曲
      if (curPlay.curMusic == null && curPlay.curList.isNotEmpty) {
        curPlay.curMusic = curPlay.curList[0];
      }
    }
    return curPlay;
  }

  ///写入
  static write() async {
    File file = new File(await AppPath.curPlayPath());
    var jsonStr = jsonEncode(curPlay);
    file.writeAsString(jsonStr);
  }
}
