import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:rong_client/device/device.dart';
import 'package:rong_client/device/mztio_device.dart';
import 'package:rong_client/device/pixie16_device.dart';


class DeviceGroup {
  DeviceGroup({
    this.name = "",
    required this.devices,
  });

  final String name;
  final List<DeviceModel> devices;
  bool running = false;

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final DeviceModel device = devices.removeAt(oldIndex);
    devices.insert(newIndex, device);
  }

  Future<void> startRun() async {
    for (var device in devices) {
      if (running) {
        print("Running, state ${device.state}");
        if (device.state != 2) continue;
      } else {
        print("Idle, state ${device.state}");
        if (device.state != 3) continue;
      }
      await device.startRun();
      print("State ${device.state}");
    }
    running = !running;
  }
}


class DeviceManagerModel extends ChangeNotifier {
  DeviceManagerModel();

  final Map<String, DeviceModel> devices = {};
  final List<DeviceGroup> groups = [];
  String selectedDevice = "";


  Future<void> init() async {
    await load();
    for (var dev in devices.values) {
      await dev.init();
    }

    Timer.periodic(
      const Duration(seconds: 1),
      (_) => refresh(),
    );
  }


  Future<void> load() async {
    // open file
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File("$path/.rong/config/devices.json");
    if (!file.existsSync()) return;

    try {
      // read information
      final jsonString = await file.readAsString();
      final managerInfo = jsonDecode(jsonString) as Map<String, dynamic>;
      // decode information
      final version = (managerInfo["version"] ?? 0) as int;
      if (version == 1) {
        List<dynamic> groupsInfo = managerInfo["groups"] as List<dynamic>;
        for (var groupInfo in groupsInfo) {
          final List<DeviceModel> deviceList = [];
          List<dynamic> devicesInfo = groupInfo["devices"] as List<dynamic>;
          for (var deviceInfo in devicesInfo) {
            if (deviceInfo["type"]! as String == "mztio") {
              final MztioDeviceModel device = MztioDeviceModel(
                name: deviceInfo["name"]! as String,
                address: deviceInfo["address"]! as String,
                port: deviceInfo["port"]! as String,
                group: groups.length,
                index: deviceList.length,
              );
              deviceList.add(device);
              devices[device.name] = device;
            } else if (deviceInfo["type"]! as String == "pixie16") {
              final Pixie16DeviceModel device = Pixie16DeviceModel(
                name: deviceInfo["name"]! as String,
                address: deviceInfo["address"]! as String,
                port: deviceInfo["port"]! as String,
                group: groups.length,
                index: deviceList.length,
              );
              deviceList.add(device);
              devices[device.name] = device;
            }
          }
          DeviceGroup group = DeviceGroup(
            name: groupInfo["name"],
            devices: deviceList
          );
          groups.add(group);
        }
      }
    } catch (e) {
      return;
    }
  }


  Future<void> save() async {
    // create and open file
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File("$path/.rong/config/devices.json");
    await file.create(recursive: true);

    // encode to JSON
    final Map<String, dynamic> content = {
      "version": 1,
      "groups": List.generate(
        groups.length,
        (int gindex) {
          return Map<String, dynamic>.from({
            "name": groups[gindex].name,
            "devices": List.generate(
              groups[gindex].devices.length,
              (int dindex) {
                return Map<String, dynamic>.from({
                  "name": groups[gindex].devices[dindex].name,
                  "address": groups[gindex].devices[dindex].address,
                  "port": groups[gindex].devices[dindex].port,
                  "type": deviceTypeName[groups[gindex].devices[dindex].type]!
                });
              }
            ),
          });
        }
      ),
    };
    // final List<dynamic> groupsInfo = [];
    // for (var group in groups) {
    //   final List<dynamic> devicesInfo = [];
    //   for (var device in group.devices) {
    //     final Map<String, dynamic> info = {
    //       "name": device.name,
    //       "address": device.address,
    //       "port": device.port,
    //       "type": deviceTypeName[device.type]!
    //     };
    //     devicesInfo.add(info);
    //   }
    //   Map<String, dynamic> groupInfo = {
    //     "name": group.name,
    //     "devices": devicesInfo,
    //   };
    //   groupsInfo.add(groupInfo);
    // }
    // final Map<String, dynamic> content = {
    //   "version":1,
    //   "groups": groupsInfo,
    // };
    // write
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(content))
    ;
  }

  void notifyManual() {
    notifyListeners();
  }

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
        port: device.port,
        group: groups.length,
        index: 0,
      );
    } else if (device.type == DeviceType.pixie16) {
      devices[device.name] = Pixie16DeviceModel(
        name: device.name,
        address: device.address,
        port: device.port,
        group: groups.length,
        index: 0,
      );
    }
    groups.add(
      DeviceGroup(
        name: "",
        devices: [devices[device.name]!],
      )
    );
    save();
  }

  void deleteDevice(String name) {
    if (!devices.containsKey(name)) {
      throw "Device name not existed: $name";
    }
    groups[devices[name]!.group].devices.remove(devices[name]!);
    if (groups[devices[name]!.group].devices.isEmpty) {
      groups.removeAt(devices[name]!.group);
      for (var i = 0; i < groups.length; ++i) {
        for (var device in groups[i].devices) {
          device.group = i;
        }
      }
    }
    devices.remove(name);
    save();
  }

  void editDevice(DeviceModel device) {
    if (!devices.containsKey(device.name)) {
      throw "Device name not existed: ${device.name}";
    }
    final DeviceModel selectedDevice = devices[device.name]!;
    final DeviceGroup group = groups[selectedDevice.group];
    // remove old one
    group.devices.removeAt(device.index);
    // build new one
    if (device.type == DeviceType.mztio) {
      devices[device.name] = MztioDeviceModel(
        name: device.name,
        address: device.address,
        port: device.port,
        group: device.group,
        index: device.index,
      );
    } else if (device.type == DeviceType.pixie16) {
      devices[device.name] = Pixie16DeviceModel(
        name: device.name,
        address: device.address,
        port: device.port,
        group: device.group,
        index: device.index,
      );
    }
    // insert new one
    group.devices.insert(device.index, devices[device.name]!);
    devices[device.name]!.init();
    save();
  }

  void changeDeviceGroup(String name, int newGroup) {
    if (!devices.containsKey(name)) return;
    final oldGroup = devices[name]!.group;
    // remove from old group
    groups[oldGroup].devices.remove(devices[name]!);
    // add new group
    if (newGroup == -1) {
      newGroup = groups.length;
      groups.add(DeviceGroup(name: "", devices: []));
    }
    // add to new group
    groups[newGroup].devices.add(devices[name]!);
    // record new group index
    devices[name]!.group = newGroup;
    // remove empty group
    if (groups[oldGroup].devices.isEmpty) {
      groups.removeAt(oldGroup);
      for (var i = oldGroup; i < groups.length; ++i) {
        for (var device in groups[i].devices) {
          device.group = i;
        }
      }
    }
    save();
  }
}