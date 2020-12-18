// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MethodResult _$MethodResultFromJson(Map<String, dynamic> json) {
  return MethodResult(
      json['state'] as int, json['error_msg'] as String, json['data']);
}

Map<String, dynamic> _$MethodResultToJson(MethodResult instance) =>
    <String, dynamic>{
      'state': instance.state,
      'error_msg': instance.error_msg,
      'data': instance.data
    };
