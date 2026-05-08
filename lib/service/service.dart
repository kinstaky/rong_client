import 'dart:io';

const int maxConnectTry = 5;

enum ServiceType { mztio, pixie16, other }

const Map<ServiceType, String> serviceTypeName = {
  ServiceType.mztio: "mztio",
  ServiceType.pixie16: "pixie16",
  ServiceType.other: "other"
};
const Map<String, ServiceType> serviceNameType = {
  "mztio": ServiceType.mztio,
  "pixie16": ServiceType.pixie16,
  "other": ServiceType.other,
};

abstract class ServiceModel {
  ServiceModel({
    required this.name,
    required this.ip,
    required this.port,
    required this.type,
    required this.index,
    required this.saveCallback,
  });

  // ServiceModel.from(ServiceModel other) {
  //   name = other.name;
  //   ip = other.ip;
  //   port = other.port;
  //   type = other.type;
  //   state = other.state;
  //   run = other.run;
  //   running = other.running;
  //   saveCallback = other.saveCallback;
  // }

  factory ServiceModel.fromJson(
    Map<String, dynamic> json,
    Function saveCallback,
  ) {
    throw UnimplementedError("fronJson is not implemented in ServiceModel");
  }

  Map<String, dynamic> toJson();

  // service name
  String name = "";
  // service address
  String ip = "";
  // service type
  String port = "";
  // service type
  ServiceType type = ServiceType.other;
  // index in profile
  int index = 0;
  // save callback from app manager
  Function saveCallback;
  // service state
  int state = 0;
  // connection error times
  int errorConnect = 0;
  // run
  int run = 0;

  Future<void> init();

  Future<void> refreshState();

  Future<void> changeRun(int newRun) async {
    run = newRun;
  }

  Future<void> loadRun() async {}

  Future<void> startRun() async {
    state = state == 0 ? 0 : (state == 2 ? 3 : 2);
  }

  Future<String> logFileName() async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isAndroid) {
      final homeDirectory = Platform.environment['HOME'];
      return "$homeDirectory/.easy_daq_client/log/"
        "${serviceTypeName[type]}_${name}_${ip}_scaler_names.log";
    }
    if (Platform.isWindows) {
      final homeDirectory = Platform.environment['USERPROFILE'];
      return "$homeDirectory/.easy_daq_client/log"
        "${serviceTypeName[type]}_${name}_${ip}_scaler_names.log";
    }
    throw UnimplementedError("Not support this platform!");

  }
}

// class DefaultServiceModel extends ServiceModel {
//   DefaultServiceModel({
//     required super.name,
//     required super.ip,
//     required super.port,
//     super.type = ServiceType.other,
//     super.index = 0,
//     required super.saveCallback,
//   });

//   @override
//   Future<void> init() async {}

//   @override
//   Future<void> refreshState() async {}

//   @override
//   Map<String, dynamic> 
// }
