import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_usb/Command.dart';
import 'package:flutter_usb/Response.dart';
import 'package:flutter_usb/UsbDevice.dart';
import 'package:flutter_usb/flutter_usb.dart';

void main() {
  FlutterUsb.enableLogger();
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
            title: const Text('Plugin example app'), leading: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
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
        await liveViewTest();
      },
    );
  }


  liveViewTest() async {
    if (Platform.isWindows) {
      //request image information (only once?)
      var arr = [
        //0x08 -> image info (eg size (for liveview))
        0x08, 16, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00,
        0x02, 192, 0xFF, 255, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00, 0x03,
        0x00, 0x00, 0x00
      ];
      /*

{byte[38]}
    [0]: 2
    [1]: 146
    [2]: 0
    [3]: 0
    [4]: 0
    [5]: 0
    [6]: 0
    [7]: 0
    [8]: 0
    [9]: 0
    [10]: 200
    [11]: 0
    [12]: 0
    [13]: 0
    [14]: 0
    [15]: 0
    [16]: 0
    [17]: 0
    [18]: 0
    [19]: 0
    [20]: 0
    [21]: 0
    [22]: 0
    [23]: 0
    [24]: 0
    [25]: 0
    [26]: 0
    [27]: 0
    [28]: 0
    [29]: 0
    [30]: 1
    [31]: 0
    [32]: 0
    [33]: 0
    [34]: 3
    [35]: 0
    [36]: 0
    [37]: 0
       */
      Response response = await FlutterUsb.sendCommand(Command(arr));
      print(response);
      //analyze image

      //position 32: ReadInt16 -> anzahl bilder
      //position : ReadInt32 -> imageInfoUnk
      //position : ReadInt32 -> imageSizeInBytes
      //position82 : ReadByte -> imageName

      //request image
      //0x09 -> image data (image itself)
      var arr2 = [
        0x09,
        16,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x02,
        192,
        255,
        255,
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
        0x01,
        0x00,
        0x00,
        0x00,
        0x03,
        0x00,
        0x00,
        0x00
      ];
      response = await FlutterUsb.sendCommand(Command(arr, outDataLength: 40000));
      print(response);
      //position 30: ReadInt32 -> unkBufferSize
      //position : ReadInt32 -> liveViewBufferSize
      //position : unkBufferSize-8 -> unkBuff
      //position : (remaining) -> buff (image data)
    }

    sendGetLiveView() {}
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
      var result = await FlutterUsb.sendCommand(new Command(arr));
      print(result);
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
      var result = await FlutterUsb.sendCommand(new Command(arr));
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
      var result2 = await FlutterUsb.sendCommand(new Command(arr2));
    }
  }
}
