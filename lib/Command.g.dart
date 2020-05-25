// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Command _$CommandFromJson(Map<String, dynamic> json) {
  return Command(
    json['outDataLength'] as int,
    (json['inData'] as List)?.map((e) => e as int)?.toList(),
  );
}

Map<String, dynamic> _$CommandToJson(Command instance) => <String, dynamic>{
      'outDataLength': instance.outDataLength,
      'inData': instance.inData,
    };
