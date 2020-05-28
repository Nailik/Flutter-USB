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
      logger.d("sendCommand $commandJson");
    }
    String result = await _channel.invokeMethod('sendCommand', commandJson);
    result = result.replaceAll(r'\', r'\\');
    if (_loggingEnabled) {
      logger.d("receivedResponse $result");
    }
    return Response.fromJson(jsonDecode(result));
  }

  static void enableLogger() {
    _loggingEnabled = true;
  }
}
