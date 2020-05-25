import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

part 'Response.g.dart';

@JsonSerializable()
class Response {
  String result;
  int outDataLength;
  List<int> inData;

  Uint8List getData(){
    return new Uint8List.fromList(inData);
  }

  Response(this.result, this.outDataLength, this.inData);

  /*
   * Json to Location object
   */
  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  /*
   * Location object to json
   */
  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}
