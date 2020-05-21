import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:flutter/services.dart';

class FlutterUsb {
  static const MethodChannel _channel = const MethodChannel('flutter_usb');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get initializeUsb async {
    return await _channel.invokeMethod('initializeUsb');
  }

  static Future<List<UsbDevice>> get getUsbDevices async {
    String version = await _channel.invokeMethod('getUsbDevices');
    version = version.replaceAll(r'\', r'\\');

    return (jsonDecode(version) as List)
        .map((e) => JsonMapper.deserialize<UsbDevice>(e))
        .toList();
  }

  static Future<String> connectToUsbDevice(UsbDevice usbDevice) async {
    return await _channel.invokeMethod('connectToUsbDevice', usbDevice.bstr);
  }

  static Future<String> sendCommand(Uint8List data) async {
    //TODO decode
    return await _channel.invokeMethod('sendCommand', data);
  }
}

@jsonSerializable
class Response {
  String result;
  int outDataLength;
  Uint8List inData;

  Response(this.result, this.outDataLength, this.inData);
}

@jsonSerializable
class UsbDevice {
  String name;
  String description;
  String bstr;

  UsbDevice(this.name, this.description, this.bstr);
}
