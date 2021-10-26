import 'dart:io';
import 'dart:convert';
import 'package:whisper/app_const/app_path.dart';
import 'package:whisper/model/data_model/config_model.dart';

///总体配置读写
class ConfigDataService {
   static ConfigModel? config;

  ///读取
  static Future<ConfigModel> read() async {
    if (config != null) {
      return config!;
    }

    //获取文件内容
    File file = new File(await AppPath.userConfigPath());
    var jsonStr = await file.readAsString();

    //文件为空 返回空对象
    if (jsonStr == "") {
      config = new ConfigModel.empty();
    } else {
      Map<String, dynamic> configMap = jsonDecode(jsonStr);
      config = new ConfigModel.fromJson(configMap);
    }
    return config!;
  }

  ///写入
  static write() async {
    File file = new File(await AppPath.userConfigPath());
    var jsonStr = jsonEncode(config);
    file.writeAsString(jsonStr);
  }
}
