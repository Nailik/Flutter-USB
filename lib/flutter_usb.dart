import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutterusb/Response.dart';

import 'Command.dart';
import 'UsbDevice.dart';

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
        .map((e) => UsbDevice.fromJson(e))
        .toList();
  }

  static Future<String> connectToUsbDevice(UsbDevice usbDevice) async {
    return await _channel.invokeMethod('connectToUsbDevice', usbDevice.bstr);
  }

  static Future<Response> sendCommand(Command command) async {
    String command_json = jsonEncode(command);
    String result =
        await _channel.invokeMethod('sendCommand', command_json);
    result = result.replaceAll(r'\', r'\\');
    return Response.fromJson(jsonDecode(result));
  }
}
