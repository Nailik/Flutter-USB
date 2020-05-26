import 'package:json_annotation/json_annotation.dart';

part 'Command.g.dart';

@JsonSerializable()
class Command {
  int outDataLength;
  List<int> inData;

  Command(this.inData, {this.outDataLength = 1024});

  /*
   * Json to Location object
   */
  factory Command.fromJson(Map<String, dynamic> json) =>
      _$CommandFromJson(json);

  /*
   * Location object to json
   */
  Map<String, dynamic> toJson() => _$CommandToJson(this);
}
