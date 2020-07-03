import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutterusb/Response.dart';
import 'package:logger/logger.dart';

import 'Command.dart';
import 'UsbDevice.dart';

class FlutterUsb {
  static var logger = Logger(printer: PrettyPrinter());
  static bool _loggingEnabled = false;
  static int maxLogLength = 100;
  static const MethodChannel _channel = const MethodChannel('flutter_usb');

  static Future<String> get platformVersion async {
    logD("platformVersion called");
    var version = await _channel.invokeMethod('getPlatformVersion');
    logD("platformVersion result: $version");
    return version;
  }

  static Future<String> get initializeUsb async {
    logD("initializeUsb called");
    var result = await _channel.invokeMethod('initializeUsb');
    logD("initializeUsb result: $result");
    return result;
  }

  static Future<List<UsbDevice>> get getUsbDevices async {
    logD("getUsbDevices called");
    String devices = await _channel.invokeMethod('getUsbDevices');
    devices = devices.replaceAll(r'\', r'\\');
    logD("getUsbDevices result: $devices");

    return (jsonDecode(devices) as List)
        .map((e) => UsbDevice.fromJson(e))
        .toList();
  }

  static Future<String> connectToUsbDevice(UsbDevice usbDevice) async {
    return await _channel.invokeMethod('connectToUsbDevice', usbDevice.bstr);
  }

  static Future<Response> sendCommand(Command command) async {
    logD("sendCommand ${command.inData.createString()}");

    List<dynamic> result = await _channel
        .invokeMethod('sendCommand', {command.outDataLength, command.inData});
    logD("sendCommand result: $result");

    Response response = Response(result[0], result[1], result[2]);
    logD("sendCommand response: ${command.inData.createString()}");

    return response;
  }

  static void enableLogger({int maxLogLengthNew = 100}) {
    maxLogLength = maxLogLengthNew;
    _loggingEnabled = true;
    logD("loggingEnabled max length $maxLogLength --------------------------");
  }

  static void disableLogger() {
    _loggingEnabled = false;
    logD("loggingDisabled ---------------------------------------------------");
  }

  static void logD(String string) {
    if (_loggingEnabled) {
      logger.d(string);
    }
  }
}

extension Test on List<int> {
  String createString() {
    String result = "";
    for (var i = 0; i < this.length && i < FlutterUsb.maxLogLength; i++) {
      String part = this[i].toRadixString(16).toString();
      if (part.length == 1) {
        result += "0";
      }
      result += "$part ";
    }
    return result;
  }
}
