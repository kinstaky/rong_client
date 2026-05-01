import 'package:flutter/material.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel({
    required this.colorValue,
    required this.brightness,
    required this.locale,
    required this.saveCallback,
  }) {
    color = Color(colorValue);
  }

  factory SettingsModel.fromJson(
    Map<String, dynamic> json,
    Function saveCallback,
  ) {
    return SettingsModel(
      colorValue: json["color"] as int,
      brightness: (json["brightness"] as int) == 0
        ? Brightness.light
        : Brightness.dark,
      locale: Locale(json["locale"] as String),
      saveCallback: saveCallback,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "color": colorValue,
      "brightness": brightness == Brightness.light ? 0 : 1,
      "locale": locale.languageCode,
    };
  }

  // theme color
  late Color color;
  // color value
  late int colorValue;
  // theme brightness, light or dark
  late Brightness brightness;
  // locale, en or zh
  late Locale locale;
  // save callback from app manager
  late Function saveCallback;


  // Future<void> init() async {
  //   // open file
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path = directory.path;
  //   final file = File("$path/.easy_daq_client/settings.json");
  //   try {
  //     // read information
  //     final jsonString = await file.readAsString();
  //     final settingsInfo = jsonDecode(jsonString) as Map<String, dynamic>;
  //     // decode information
  //     final version = (settingsInfo["version"] ?? 0) as int;
  //     if (version == 0) {
  //       colorValue = 0xFFF78A4B;
  //       color = Color(0xFFF79A4B);
  //       brightness = Brightness.light;
  //       locale = Locale("en");
  //     } else if (version == 1) {
  //       colorValue = settingsInfo["color"] as int;
  //       color = Color(colorValue);
  //       brightness = (settingsInfo["brightness"] as int) == 0
  //           ? Brightness.light
  //           : Brightness.dark;
  //       locale = Locale(settingsInfo["locale"] as String);
  //     }
  //   } catch (e) {
  //     colorValue = 0xFFF78A4B;
  //     color = Color(0xFFF79A4B);
  //     brightness = Brightness.light;
  //     locale = Locale("en");
  //   }
  // }

  // Future<void> save() async {
  //   // create and open file
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path = directory.path;
  //   final file = File("$path/.easy_daq_client/settings.json");
  //   await file.create(recursive: true);
  //   // encode
  //   final Map<String, dynamic> content = {
  //     "version": 1,
  //     "color": colorValue,
  //     "brightness": brightness == Brightness.light ? 0 : 1,
  //     "locale": locale.languageCode,
  //   };
  //   await file.writeAsString(JsonEncoder.withIndent('  ').convert(content));
  // }

  void updateThemeColor(int value) {
    colorValue = value;
    color = Color(colorValue);
    notifyListeners();
    saveCallback();
  }

  void updateBrightness(Brightness b) {
    brightness = b;
    notifyListeners();
    saveCallback();
  }

  void updateLocale(Locale l) {
    locale = l;
    notifyListeners();
    saveCallback();
  }
}