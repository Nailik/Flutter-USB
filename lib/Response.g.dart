// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) {
  return Response(
    json['result'] as String,
    json['outDataLength'] as int,
    (json['inData'] as List)?.map((e) => e as int)?.toList(),
  );
}

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'result': instance.result,
      'outDataLength': instance.outDataLength,
      'inData': instance.inData,
    };
