const int maxConnectTry = 5;

enum DeviceType {
  mztio, pixie16, other
}

const Map<DeviceType, String> deviceTypeName = {
  DeviceType.mztio : "mztio",
  DeviceType.pixie16 : "pixie16",
  DeviceType.other : "other"
};
const Map<String, DeviceType> deviceNameType = {
  "mztio" : DeviceType.mztio,
  "pixie16" : DeviceType.pixie16,
  "other": DeviceType.other,
};

abstract class DeviceModel {
  DeviceModel({
    required this.name,
    required this.address,
    required this.port,
    required this.type,
  });


  DeviceModel.from(DeviceModel other) {
    name = other.name;
    address = other.address;
    port = other.port;
    type = other.type;
  }


  Map<String, dynamic> toJson() => {
		'name': name,
		'address': address,
    'port': port,
    'type': deviceTypeName[type]!,
	};

  // device name
  String name = "";
  // device address
  String address = "";
  // device type
  String port = "";
  // device type
  DeviceType type = DeviceType.other;
  // device state
  int state = 0;
  // connection error times
  int errorConnect = 0;


  Future<void> init();

  Future<void> refreshState();
}


class DefaultDeviceModel extends DeviceModel {
  DefaultDeviceModel({
    required super.name,
    required super.address,
    required super.port,
    super.type = DeviceType.other,
  });

  DefaultDeviceModel.fromJson(Map<String, dynamic> json)
		: super(
			name: json['name'] as String,
			address: json['address'] as String,
      port: json['port'] as String,
      type: deviceNameType[json['type'] as String]!,
		);


  @override
  Future<void> init() async {}

  @override
  Future<void> refreshState() async {}
}