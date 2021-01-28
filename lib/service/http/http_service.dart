import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:whisper/model/music_model.dart';
import 'package:whisper/service/http/response_model.dart';
import 'package:whisper/view/common_view/dialog_view.dart';

///网络请求服务
class HttpService {
  // 服务器地址
  static var _baseUrl = "47.105.57.58:8077";
  static Utf8Decoder decoder = new Utf8Decoder();

  ///拼接url
  static String _getUrl(
      String module, String methodUrl, MusicSource musicSource) {
    var url = "$module/$methodUrl/${musicSource.name}";
    return url;
  }

  ///GET
  static Future<Object> get(
      String module, String methodUrl, MusicSource musicSource,
      [Map<String, String> queryParameters, bool showNotice = true]) async {
    // 构造url
    var url = _getUrl(module, methodUrl, musicSource);
    var uri = new Uri.http(_baseUrl, url, queryParameters);

    //错误信息
    var errorMsg = "";

    //请求
    try {
      http.Response response = await http.get(uri.toString(), // post地址
          headers: {
            "content-type": "application/json;charset=UTF-8"
          } //设置content-type为json
          );
      if (response.statusCode == HttpStatus.ok) {
        //请求成功
        var jsonStr = decoder.convert(response.bodyBytes);
        Map json = jsonDecode(jsonStr);
        var data = MethodResult.fromJson(json);

        if (data.state == 1) {
          //接口正常结果
          return data.data;
        } else {
          //接口异常结果
          errorMsg = data.error_msg;
        }
      } else {
        errorMsg = "[请求失败]$methodUrl";
      }
    } catch (exception) {
      errorMsg = "[请求失败]$methodUrl";
    }

    //弹出提示
    if (showNotice)
      DialogView.showNoticeView(errorMsg,
          icon: Icons.error_outline, dissmissMilliseconds: 1000);

    throw Exception(errorMsg);
  }

  ///post
  static Future<Object> post(
      String module, String methodUrl, MusicSource musicSource,
      {Map<String, String> queryParameters,
      Object body,
      bool showNotice = true}) async {
    // 构造url
    var url = _getUrl(module, methodUrl, musicSource);
    var uri = new Uri.http(_baseUrl, url, queryParameters);

    //错误信息
    var errorMsg = "";

    try {
      // post请求
      http.Response response = await http.post(uri.toString(), // post地址
          headers: {
            "content-type": "application/json;charset=UTF-8"
          }, //设置content-type为json
          body: jsonEncode(body) //json参数
          );

      if (response.statusCode == HttpStatus.ok) {
        //请求成功
        var jsonStr = decoder.convert(response.bodyBytes);
        Map json = jsonDecode(jsonStr);
        var data = MethodResult.fromJson(json);

        if (data.state == 1) {
          //接口正常结果
          return data.data;
        } else {
          //接口异常结果
          errorMsg = data.error_msg;
        }
      } else {
        errorMsg = "[请求失败]$methodUrl";
      }
    } catch (exception) {
      errorMsg = "[请求失败]$methodUrl";
    }

    //弹出提示
    if (showNotice)
      DialogView.showNoticeView(errorMsg,
          icon: Icons.error_outline, dissmissMilliseconds: 1000);

    throw Exception(errorMsg);
  }
}
