import 'dart:async';
// import 'dart:io';

import 'package:grpc/grpc.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:hive_flutter/hive_flutter.dart';

import 'package:rong_client/device/device.dart';
import 'package:rong_client/generated/pixie16_rong.pbgrpc.dart';


class Pixie16DeviceModel extends DeviceModel {
  Pixie16DeviceModel({
    required super.name,
    required super.address,
    required super.port,
    super.type = DeviceType.pixie16,
    required super.group,
    required super.index,
  }) {
    init();
  }

  late pixie16Client stub;

  @override
  Future<void> init() async {
    stub = pixie16Client(
      ClientChannel(
        address,
        port: int.parse(port),
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          connectTimeout: Duration(seconds: 1),
        )
      )
    );
  }

  @override
  Future<void> refreshState() async {
    if (errorConnect >= maxConnectTry) return;
    try {
      final Request request = Request(type: 0);
      final response = await stub.getState(request);
      state = response.status == 1 ? 3 : 1;
      errorConnect = 0;
    } catch (e) {
      ++errorConnect;
      state = 0;
    }
  }

}
