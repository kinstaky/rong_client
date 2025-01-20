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
    required this.group,
    required this.index,
  });


  DeviceModel.from(DeviceModel other) {
    name = other.name;
    address = other.address;
    port = other.port;
    type = other.type;
    group = other.group;
    state = other.state;
    run = other.run;
    running = other.running;
  }


  // device name
  String name = "";
  // device address
  String address = "";
  // device type
  String port = "";
  // device type
  DeviceType type = DeviceType.other;
  // device group
  int group = 0;
  // index in group
  int index = 0;
  // device state
  int state = 0;
  // connection error times
  int errorConnect = 0;
  // run
  int run = 0;
  // run status
  bool running = false;


  Future<void> init();

  Future<void> refreshState();

  Future<void> changeRun(int newRun) async {
    run = newRun;
  }

  Future<void> startRun() async {
    running = !running;
  }
}


class DefaultDeviceModel extends DeviceModel {
  DefaultDeviceModel({
    required super.name,
    required super.address,
    required super.port,
    super.type = DeviceType.other,
    super.group = 0,
    super.index = 0,
  });

  @override
  Future<void> init() async {}

  @override
  Future<void> refreshState() async {}
}