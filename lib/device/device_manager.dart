import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:rong_client/device/device.dart';
import 'package:rong_client/device/mztio_device.dart';
import 'package:rong_client/device/pixie16_device.dart';


class DeviceManagerModel extends ChangeNotifier {
  DeviceManagerModel();

  Future<void> init() async {
    // open file
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File("$path/.rong/config/devices.json");
    if (!file.existsSync()) return;

    try {
      // read information
      final jsonString = await file.readAsString();
      final deviceInfo = jsonDecode(jsonString) as Map<String, dynamic>;
      // decode information
      final version = (deviceInfo["version"] ?? 0) as int;
      final deviceCount = (deviceInfo["deviceCount"] ?? 0) as int;
      if (version == 1) {
        for (var i = 0; i < deviceCount; ++i) {
          DefaultDeviceModel device = DefaultDeviceModel.fromJson(
            deviceInfo["device$i"] as Map<String, dynamic>
          );
          if (device.type == DeviceType.mztio) {
            devices[device.name] = MztioDeviceModel(
              name: device.name,
              address: device.address,
              port: device.port
            );
          } else if (device.type == DeviceType.pixie16) {
            devices[device.name] = Pixie16DeviceModel(
              name: device.name,
              address: device.address,
              port: device.port
            );
          }
        }
      }
    } catch (e) {
      return;
    }

    for (var dev in devices.values) {
      await dev.init();
    }

    Timer.periodic(
      const Duration(seconds: 1),
      (_) => refresh(),
    );
  }

  Future<void> saveDevice() async {
    // create and open file
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File("$path/.rong/config/devices.json");
    await file.create(recursive: true);

    // encode to JSON
    final Map<String, dynamic> content = {
      "version": 1,
      "deviceCount": devices.length,
    };
    int index = 0;
    for (var device in devices.values) {
      content["device$index"] = device.toJson();
      ++index;
    }
    // write
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(content))
    ;
  }

  final Map<String, DeviceModel> devices = {};
  String selectedDevice = "";

  Future<void> refresh() async {
    for (final dev in devices.values) {
      if (dev.type == DeviceType.mztio && dev.name == selectedDevice) {
        await (dev as MztioDeviceModel).refreshScaler();
      } else {
        await dev.refreshState();
      }
    }
    notifyListeners();
  }

  void addDevice(DeviceModel device) {
    if (devices.containsKey(device.name)) {
      throw "Device name existed: ${device.name}";
    }
    if (device.type == DeviceType.mztio) {
      devices[device.name] = MztioDeviceModel(
        name: device.name,
        address: device.address,
        port: device.port
      );
    } else if (device.type == DeviceType.pixie16) {
      devices[device.name] = Pixie16DeviceModel(
        name: device.name,
        address: device.address,
        port: device.port
      );
    }
    saveDevice();
  }

  void deleteDevice(String name) {
    if (!devices.containsKey(name)) {
      throw "Device name not existed: $name";
    }
    devices.remove(name);
    saveDevice();
  }

  void editDevice(DeviceModel device) {
    if (!devices.containsKey(device.name)) {
      throw "Device name not existed: ${device.name}";
    }
    if (device.type == DeviceType.mztio) {
      devices[device.name] = MztioDeviceModel(
        name: device.name,
        address: device.address,
        port: device.port
      );
    } else if (device.type == DeviceType.pixie16) {
      devices[device.name] = Pixie16DeviceModel(
        name: device.name,
        address: device.address,
        port: device.port
      );
    }
    device.init();
    saveDevice();
  }
}