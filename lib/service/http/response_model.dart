import 'package:json_annotation/json_annotation.dart';

part 'response_model.g.dart';

@JsonSerializable()
class MethodResult {
  int state;
  String error_msg;
  Object data;

  MethodResult(this.state, this.error_msg, this.data);

  factory MethodResult.fromJson(Map<String, dynamic> json) =>
      _$MethodResultFromJson(json);
  Map<String, dynamic> toJson() => _$MethodResultToJson(this);
}
