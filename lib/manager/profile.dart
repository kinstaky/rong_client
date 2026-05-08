import 'dart:async';
import 'package:flutter/material.dart';

import '../service/service.dart';
import '../service/mztio_service.dart';
import '../service/pixie16_service.dart';

class ProfileModel extends ChangeNotifier {
  // profile name
  late String name;
  // services
  late Map<String, ServiceModel> services;
  // selected service
  String selectedService = "";
  // save callback from app manager
  Function saveCallback;
  // running state
  bool allRunning = false;
  bool allStopeed = false;

  ProfileModel({
    required this.name,
    required this.services,
    required this.saveCallback,
  });

  factory ProfileModel.fromJson(
    Map<String, dynamic> json,
    Function saveCallback,
  ) {
    return ProfileModel(
      name: json["name"],
      services: Map.fromIterable(
        json["services"] as List<dynamic>,
        key: (item) => item["name"],
        value: (item) {
          switch (serviceNameType[item["type"]]) {
            case ServiceType.mztio:
              return MztioServiceModel.fromJson(item, saveCallback);
            case ServiceType.pixie16:
              return Pixie16ServiceModel.fromJson(item, saveCallback);
            default:
              return ServiceModel.fromJson(item, saveCallback);
          }
        },
      ),
      saveCallback: saveCallback
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "services": services.values.toList().map(
        (item) => item.toJson()
      ).toList(),
    };
  }

  void refreshRunning() {
    allRunning = services.values.every((service) => service.state == 0 || service.state == 2);
    allStopeed = services.values.every((service) => service.state == 0 || service.state == 3);
  }

  Future<void> init() async {
    for (var service in services.values) {
      await service.init();
    }

    refreshRunning();

    Timer.periodic(
      const Duration(seconds: 1),
      (_) => refresh(),
    );
  }

  void notifyManual() {
    notifyListeners();
  }

  Future<void> refresh() async {
    for (final service in services.values) {
      if (service.type == ServiceType.mztio && service.name == selectedService) {
        await (service as MztioServiceModel).refreshScaler();
      } else {
        await service.refreshState();
      }
    }
    refreshRunning();
    notifyListeners();
  }

  void addService(Map<String, dynamic> service) {
    if (services.containsKey(service["name"])) {
      throw "Service name existed: ${service['name']}";
    }
    if (service["type"] == ServiceType.mztio) {
      services[service["name"]] = MztioServiceModel(
        name: service["name"],
        ip: service["ip"],
        port: service["port"],
        index: services.length,
        saveCallback: saveCallback,
        scalerNames: List.generate(scalerNum, (index) => "$index"),
      );
    } else if (service["type"] == ServiceType.pixie16) {
      services[service["name"]] = Pixie16ServiceModel(
        name: service["name"],
        ip: service["ip"],
        port: service["port"],
        index: services.length,
        saveCallback: saveCallback,
      );
    }
    refreshRunning();
    saveCallback();
  }

  void deleteService(String name) {
    if (!services.containsKey(name)) {
      throw "Service name not existed: $name";
    }
    final removeIndex = services[name]!.index;
    services.remove(name);
    for (final service in services.values) {
      if (service.index > removeIndex) {
        service.index -= 1;
      }
    }
    refreshRunning();
    saveCallback();
  }

  void editService(Map<String, dynamic> service) {
    if (!services.containsKey(service["name"])) {
      throw "Service name not existed: ${service['name']}";
    }
    // build new one
    if (service["type"] == ServiceType.mztio) {
      services[service["name"]] = MztioServiceModel(
        name: service["name"],
        ip: service["ip"],
        port: service["port"],
        index: service["index"],
        saveCallback: saveCallback,
        scalerNames: (service as MztioServiceModel).scalerNames,
      );
    } else if (service["type"] == ServiceType.pixie16) {
      services[service["name"]] = Pixie16ServiceModel(
        name: service["name"],
        ip: service["ip"],
        port: service["port"],
        index: service["index"],
        saveCallback: saveCallback,
      );
    }
    // insert new one
    services[service["name"]]!.init();
    refreshRunning();
    saveCallback();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    for (final service in services.values) {
      if (service.index == oldIndex) {
        service.index = newIndex;
      } else if (
        oldIndex < newIndex
        && service.index > oldIndex
        && service.index <= newIndex
      ) {
        service.index -= 1;
      } else if (
        oldIndex > newIndex
        && service.index > newIndex
        && service.index <= oldIndex
      ) {
        service.index += 1;
      }
    }
  }

  Future<void> startRun() async {
    if (allRunning && allStopeed) return;
    if (!allRunning && !allStopeed) return;
    List<Future> futures = [];
    if (allRunning) {
      for (var service in services.values) {
        print("${service.name}'s state is ${service.state}");
        if (service.state != 2) continue;
        futures.add(service.startRun());
      }
    } else {
      for (var service in services.values) {
        print("${service.name}'s state is ${service.state}");
        if (service.state != 3) continue;
        futures.add(service.startRun());
      }
    }
    await Future.wait(futures);
  }
}
