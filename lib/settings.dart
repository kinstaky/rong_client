import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


class SettingsModel extends ChangeNotifier {
  SettingsModel();

  // theme color
  late Color color;
  // color value
  late int colorValue;
  // theme brightness, light or dark
  late Brightness brightness;
  // locale, en or zh
  late Locale locale;


  Future<void> init() async {
    // open file
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File("$path/.rong/config/settings.json");
    try {
      // read information
      final jsonString = await file.readAsString();
      final settingsInfo = jsonDecode(jsonString) as Map<String, dynamic>;
      // decode information
      final version = (settingsInfo["version"] ?? 0) as int;
      if (version == 0) {
        colorValue = 0xFFF78A4B;
        color = Color(0xFFF79A4B);
        brightness = Brightness.light;
        locale = Locale("en");
      } else if (version == 1) {
        colorValue = settingsInfo["color"] as int;
        color = Color(colorValue);
        brightness = (settingsInfo["brightness"] as int) == 0
          ? Brightness.light
          : Brightness.dark;
        locale = Locale(settingsInfo["locale"] as String);
      }
    } catch (e) {
      colorValue = 0xFFF78A4B;
      color = Color(0xFFF79A4B);
      brightness = Brightness.light;
      locale = Locale("en");
    }
  }


  Future<void> save() async {
    // create and open file
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File("$path/.rong/config/settings.json");
    await file.create(recursive: true);
    // encode
    final Map<String, dynamic> content = {
      "version": 1,
      "color": colorValue,
      "brightness": brightness == Brightness.light ? 0 : 1,
      "locale": locale.languageCode,
    };
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(content)
    );
  }


  void updateThemeColor(value) {
    colorValue = value;
    color = Color(colorValue);
    notifyListeners();
    save();
  }


  void updateBrightness(Brightness b) {
    brightness = b;
    notifyListeners();
    save();
  }


  void updateLocale(Locale l) {
    locale = l;
    notifyListeners();
    save();
  }

}