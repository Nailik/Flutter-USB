import 'dart:typed_data';

class Response {
  String result;
  double outDataLength;
  List<int> inData;

  Uint8List getData(){
    return new Uint8List.fromList(inData);
  }

  Response(this.result, this.outDataLength, this.inData);
}
