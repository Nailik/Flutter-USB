import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutterusb/flutter_usb.dart';
import 'main.reflectable.dart' show initializeReflectable;

void main() {
  initializeReflectable();
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await FlutterUsb.initializeUsb; 

    setState(() {
      _initialized = true;
    });
  }

  Widget cameraList() {
    if (_initialized) {
      return FutureBuilder<List<UsbDevice>>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                UsbDevice device = snapshot.data[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.description),
                  onTap: () async {
                    await FlutterUsb.connectToUsbDevice(device);
                    await sendConnectCommand();
                    setState(() {
                      _connected = true;
                    });
                  },
                );
              },
            );
          } else {
            return Container();
          }
        },
        future: FlutterUsb.getUsbDevices,
      );
    } else {
      return getBody();
    }
  }

  Widget getBody() {
    if (true) {
      return Column(
        children: [
          MaterialButton(
            child: Text("takePicture"),
            onPressed: () {
            },
          )
        ],
      );
    } else {
      return cameraList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(child: cameraList()),
      ),
    );
  }

  sendConnectCommand() async{
    if(Platform.isWindows){
      var arr = [ 0x01, 0x92, 0x00 , 0x00 , 0x00, 0x00, 0x00 , 0x00 , 0x00 , 0x00, 0x01 ,
        0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 ,
        0x00, 0x00, 0x00, 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ,
        0x00 ,   0x00 , 0x00 , 0x03 , 0x00 , 0x00 , 0x00 ];
      var result = await FlutterUsb.sendCommand(new Uint8List.fromList(arr));
    }else if(Platform.isAndroid){
      var arr = [ 0x10,  0x00,  0x00,  0x00,  0x01,  0x00,  0x02, 0x10,  0x00,  0x00,  0x00,  0x00,  0x01,  0x00, 0x00,  0x00 ];
      var result = await FlutterUsb.sendCommand(new Uint8List.fromList(arr));
      var arr2 = [ 0x12,  0x00,  0x00,  0x00,  0x02,  0x00,  0x01, 0x92,  0x03,  0x00,  0x00,  0x00,  0x01,  0x00,  0x00,  0x00,  0x00,  0x00 ];
      var result2 = await FlutterUsb.sendCommand(new Uint8List.fromList(arr2));
    }
  }

}
