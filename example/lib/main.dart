import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutterusb/UsbDevice.dart';
import 'package:flutterusb/flutter_usb.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: deviceList(),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0)),
                child: Text("reload"),
                color: Colors.blue,
                onPressed: () {
                  setState(() {
                    /*reload*/
                  });
                },
              )
            ],
          )),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await FlutterUsb.initializeUsb;

    setState(() {
      _initialized = true;
    });
  }

  Widget deviceList() {
    if (_initialized) {
      return FutureBuilder<List<UsbDevice>>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return getListTile(snapshot.data[index]);
              },
            );
          } else {
            return Container();
          }
        },
        future: FlutterUsb.getUsbDevices,
      );
    }
    return Container();
  }

  Widget getListTile(UsbDevice device) {
    return ListTile(
      title: Text(device.name),
      subtitle: Text(device.description),
      onTap: () async {
        await FlutterUsb.connectToUsbDevice(device);
        await sendConnectCommand();
      },
    );
  }

  sendConnectCommand() async {
    if (Platform.isWindows) {
      var arr = [
        0x01,
        0x92,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x03,
        0x00,
        0x00,
        0x00,
        0x03,
        0x00,
        0x00,
        0x00
      ];
      var result = await FlutterUsb.sendCommand(new Uint8List.fromList(arr));
    } else if (Platform.isAndroid) {
      var arr = [
        0x10,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x02,
        0x10,
        0x00,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00
      ];
      var result = await FlutterUsb.sendCommand(new Uint8List.fromList(arr));
      var arr2 = [
        0x12,
        0x00,
        0x00,
        0x00,
        0x02,
        0x00,
        0x01,
        0x92,
        0x03,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00
      ];
      var result2 = await FlutterUsb.sendCommand(new Uint8List.fromList(arr2));
    }
  }
}
