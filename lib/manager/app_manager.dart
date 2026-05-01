import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'profile.dart';
import 'settings.dart';

class AppManager extends ChangeNotifier {
  AppManager();

  late SettingsModel settings;
  late List<ProfileModel> profiles;
  late int currentProfile;

  Future<String> configFileName() async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isAndroid) {
      final homeDirectory = Platform.environment['HOME'];
      return "$homeDirectory/.easy_daq_client/config.json";
    }
    if (Platform.isWindows) {
      final homeDirectory = Platform.environment['USERPROFILE'];
      return "$homeDirectory/.easy_daq_client/config.json";
    }
    throw UnimplementedError("Not support this platform!");
  }

  Future<void> load() async {
    // open file
    final file = File(await configFileName());
    if (!file.existsSync()) {
      settings = SettingsModel(
        colorValue: 0xFFF78A4B,
        brightness: Brightness.light,
        locale: Locale("en"),
        saveCallback: save,
      );
      profiles = [
        ProfileModel(name: "default", services: {}, saveCallback: save),
      ];
      currentProfile = 0;
      save();
    } else {
      final file = File(await configFileName());
      final jsonString = await file.readAsString();
      final configData = jsonDecode(jsonString) as Map<String, dynamic>;
      final version = configData["version"];
      if (version == 1) {
        settings = SettingsModel.fromJson(configData["settings"], save);
        final profileData = configData["profiles"] as List<dynamic>;
        profiles = [];
        for (final json in profileData) {
          profiles.add(ProfileModel.fromJson(json, save));
        }
        currentProfile = configData["currentProfile"];
      }
    }
    for (final profile in profiles) {
      await profile.init();
    }
  }

  Future<void> save() async {
    // create and open file
    final file = File(await configFileName());
    await file.create(recursive: true);
    final Map<String, dynamic> content = {
      "version": 1,
      "settings": settings.toJson(),
      "profiles": profiles.map((profile) => profile.toJson()).toList(),
      "currentProfile": currentProfile,
    };
    await file.writeAsString(JsonEncoder.withIndent('  ').convert(content));
  }
}