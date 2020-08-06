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
    if (this.sendTimeout == null) {
      sendTimeout = FlutterUsb.sendTimeout;
    }
    if (this.receiveTimeout == null) {
      receiveTimeout = FlutterUsb.receiveTimeout;
    }
  }
}
