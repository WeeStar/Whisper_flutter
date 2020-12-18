import 'dart:io';
import 'package:path_provider/path_provider.dart';

//app关键路径
class AppPath {
  //用户数据路径
  static String _userConfigPath;

  static userConfigPath() async {
    if (_userConfigPath != null) {
      return _userConfigPath;
    }

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _userConfigPath = '$appDocPath/UserConfigPath.json';

    //文件不存在则创建
    File file = new File(_userConfigPath);
    if (!file.existsSync()) {
      file.createSync();
    }
    return _userConfigPath;
  }

  //历史数据路径
  static String _hisPath;

  static hisPath() async {
    if (_hisPath != null) {
      return _hisPath;
    }

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _hisPath = '$appDocPath/His.json';

    //文件不存在则创建
    File file = new File(_hisPath);
    if (!file.existsSync()) {
      file.createSync();
    }
    return _hisPath;
  }

  //我的歌单数据路径
  static String _mySheetsPath;

  static mySheetsPath() async {
    if (_mySheetsPath != null) {
      return _mySheetsPath;
    }

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _mySheetsPath = '$appDocPath/MySheets.json';

    //文件不存在则创建
    File file = new File(_mySheetsPath);
    if (!file.existsSync()) {
      file.createSync();
    }
    return _mySheetsPath;
  }

  //我的歌单数据路径
  static String _curPlayPath;

  static curPlayPath() async {
    if (_curPlayPath != null) {
      return _curPlayPath;
    }

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _curPlayPath = '$appDocPath/CurPlay.json';

    //文件不存在则创建
    File file = new File(_curPlayPath);
    if (!file.existsSync()) {
      file.createSync();
    }
    return _curPlayPath;
  }
}
