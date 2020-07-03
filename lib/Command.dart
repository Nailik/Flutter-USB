import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Command {
  double outDataLength;
  List<int> inData;

  Command(this.inData, {this.outDataLength = 1024});
}
