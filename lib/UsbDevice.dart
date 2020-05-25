import 'package:json_annotation/json_annotation.dart';

part 'UsbDevice.g.dart';

@JsonSerializable()
class UsbDevice {
  String name;
  String description;
  String bstr;

  UsbDevice(this.name, this.description, this.bstr);

  /*
   * Json to Location object
   */
  factory UsbDevice.fromJson(Map<String, dynamic> json) =>
      _$UsbDeviceFromJson(json);

  /*
   * Location object to json
   */
  Map<String, dynamic> toJson() => _$UsbDeviceToJson(this);
}
