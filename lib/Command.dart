import 'package:flutter_usb/flutter_usb.dart';

class Command {
  int outDataLength;
  List<int> inData;
  int sendTimeout;
  int receiveTimeout;
  List<int> endIdentifier; //when this comes in it stops reading

  Command(this.inData,
      {this.outDataLength = 1024,
      this.sendTimeout,
      this.receiveTimeout,
      this.endIdentifier}) {
    if (sendTimeout == null) {
      sendTimeout = FlutterUsb.sendTimeout;
    }
    if (receiveTimeout == null) {
      receiveTimeout = FlutterUsb.receiveTimeout;
    }
  }

  List<dynamic> get commandList {
    List<dynamic> list = List<dynamic>();
    list.add(outDataLength);
    list.add(inData.toByteList());
    list.add(sendTimeout);
    list.add(receiveTimeout);
    list.add(endIdentifier);
    return list;
  }
}
