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
    String commandJson = jsonEncode(command);
    if (_loggingEnabled) {
      logger.d("sendCommand ${listToHexString(command.inData)}");
    }
    String result = await _channel.invokeMethod('sendCommand', commandJson);
    result = result.replaceAll(r'\', r'\\');
    Response response = Response.fromJson(jsonDecode(result));
    if (_loggingEnabled) {
      logger.d("receivedResponse ${listToHexString(response.inData)}");
    }
    return response;
  }

  static void enableLogger() {
    _loggingEnabled = true;
  }

  static String listToHexString(List<int> inData) {
    String result = "";
    for (var i = 0; i < inData.length - 1; i += 2) {
      result +=
      "${inData[i].toRadixString(8).toString()}${inData[i + 1].toRadixString(
          8)} ";
    }
    return result;
  }
}
