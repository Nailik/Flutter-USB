// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UsbDevice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsbDevice _$UsbDeviceFromJson(Map<String, dynamic> json) {
  return UsbDevice(
    json['name'] as String,
    json['description'] as String,
    json['bstr'] as String,
  );
}

Map<String, dynamic> _$UsbDeviceToJson(UsbDevice instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'bstr': instance.bstr,
    };
