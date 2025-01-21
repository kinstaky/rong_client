import 'dart:async';

import 'package:grpc/grpc.dart';

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
    errorConnect = 0;
    init();
  }

  // gRPC stub
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
      state = response.status;
      errorConnect = 0;
    } catch (e) {
      ++errorConnect;
      state = 0;
    }
  }

  @override
  Future<void> changeRun(int newRun) async {
    try {
      final Action action = Action(
        type: 2,
        option: newRun,
      );
      final reply = await stub.runControl(action);
      if (reply.status == newRun) {
        run = newRun;
      }
    } catch (e) {
      // print("Caught error: $e");
    }
  }

  @override
  Future<void> loadRun() async {
    try {
      final Action action = Action(type: 0);
      final reply = await stub.runControl(action);
      run = reply.status;
    } catch (e) {
      // print("Caught error: $e");
    }
  }

  @override
  Future<void> startRun() async {
    try {
      final Action action = Action(type: 1);
      final reply = await stub.runControl(action);
      state = reply.status == 0 ? 3 : 2;
      await loadRun();
    } catch (e) {
      // print("Caught error: $e");
    }
  }

}
