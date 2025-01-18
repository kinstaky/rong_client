import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:rong_client/device/device.dart';
import 'package:rong_client/generated/ecl_rong.pbgrpc.dart';


const int scalerNum = 32;

enum ScalerMode {
  modeLive, modeHistory
}
enum ScalerLiveMode {
  mode2m, mode20m, mode2h, mode24h,
}
const scalerLiveModeAvg = [
  1, 10, 60, 720,
];

class ParseResult {
  ParseResult({
    required this.index,
    required this.status,
    required this.position,
    required this.length,
  });

  String message() {
    switch (status) {
      case 1:
        return "Invalid character.\n";
      case 2:
        return "Variable starts with digits.\n";
      case 3:
        return "Vriable starts with underscore '_'.\n";
      case 101:
        return "Invalid token.\n";
      case 102:
        return "Token can't be shifted.\n";
      case 103:
        return "Invalid token type.\n";
      case 104:
        return "Invalid action type.\n";
      case 201:
        return "Tokens less than 3.\n";
      case 202:
        return "Invalid token type.\n";
      case 203:
        return "Multiple source of port.\n";
      case 204:
        return "Input and output in the same port.\n";
      case 205:
        return "Invalid scaler input.\n";
      case 206:
        return "LEMO and LVDS in the same port.\n";
      case 207:
        return "Undefined variable.\n";
      case 208:
        return "Nested downscale expression.\n";
      case 209:
        return "Invalid external clock source.\n";
      case 300:
        return "Generate error.\n";
      case 400:
        return "Connect server failed.\n";
      default:
        return "Undefined error.\n";
    }
  }

  int index = -1;
  int status = 0;
  int position = 0;
  int length = 0;
}

class MztioDeviceModel extends DeviceModel {
  MztioDeviceModel({
    required super.name,
    required super.address,
    required super.port,
    super.type = DeviceType.mztio,
    this.scalerNames
  }) {
    errorConnect = 0;
    scalerMode = 0;
    scalerLiveMode = 0;
    for (var i = 0; i < scalerNum; ++i) {
      scaler.add(0);
      visual.add(false);
      visualScaler.add([]);
      for (var j = 0; j < 120; ++j) {
        visualScaler[i].add(0);
      }
    }
    if (scalerNames == null) {
      scalerNames = [];
      for (var i = 0; i < scalerNum; ++i) {
        scalerNames!.add("$i");
      }
    }
    init();
  }


  // stub
  late eclClient stub;
  // scaler mode
  int scalerMode = 0;
  // scaler live mode
  int scalerLiveMode = 0;
  // current scaler value
  List<int> scaler = [];
  // scaler names
  List<String>? scalerNames = [];
  // visual scaler
  List<bool> visual = [];
  // visual scaler data
  List<List<int>> visualScaler = [];
  // calculated scaler value
  int avgNumber = 0;
  // config file name
  DateTime configTime = DateTime.now();
  // config expressions
  List<String> expressions = [];


  @override
  Future<void> init() async {
    stub = eclClient(
      ClientChannel(
        address,
        port: int.parse(port),
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          connectTimeout: Duration(seconds: 1),
        ),
      ),
    );
    await getConfig();
    await loadScalerNames();
  }

  @override
  Future<void> refreshState() async {
    if (errorConnect >= maxConnectTry) return;
    try {
      final Request request = Request(type: 0);
      final response = await stub.getState(request);
      state = response.value == 1 ? 3 : 1;
      errorConnect = 0;
    } catch (e) {
      print("Caught error: $e");
      ++errorConnect;
      state = 0;
    }
  }

  Future<void> saveScalerNames() async {
    // create and open file
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File(
      "$path/.rong/config/mztio/"
      "mztio_${name}_${address}_${port}_scaler.json"
    );
    await file.create(recursive: true);
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(
        scalerNames
      )
    );

    if (scalerNames == null) return;
    final logFile = File(
      "$path/.rong/mztio/scaler_names/"
      "mztio_${name}_${address}_${port}_log.txt"
    );
    String content = "";
    if (!logFile.existsSync()) {
      // file not exists, create title
      await logFile.create(recursive: true);
      content = "Year,Month,Day,Hour,Minute,Second";
      for (var i = 0; i < scalerNum; ++i) {
        content += ",$i";
      }
    } else {
      // read old content
      content = await logFile.readAsString();
    }
    // add new content
    final currentTime = DateTime.now();
    content += "${Platform.lineTerminator}"
      "${currentTime.year},${currentTime.month},${currentTime.day},"
      "${currentTime.hour},${currentTime.minute},${currentTime.second}";
    for (var i = 0; i < scalerNames!.length; ++i) {
      content += ",${scalerNames![i]}";
    }
    await logFile.writeAsString(content);
  }

  Future<void> loadScalerNames() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File(
      "$path/.rong/config/mztio/"
      "mztio_${name}_${address}_${port}_scaler.json"
    );
    if (!file.existsSync()) {
      scalerNames = [];
      for (var i = 0; i < scalerNum; ++i) {
        scalerNames!.add("$i");
      }
    } else {
      String content = await file.readAsString();
      final names = jsonDecode(content) as List<dynamic>;
      scalerNames = [];
      for (var name in names) {
        scalerNames!.add(name as String);
      }
    }
  }

  Future<void> refreshScaler() async {
    try {
      final Request request = Request(type: 0);
      var index = 0;
      await for (var response in stub.getScaler(request)) {
        if (index < scalerNum) scaler[index] = response.value;
        ++index;
      }
      if (ScalerMode.values[scalerMode] == ScalerMode.modeLive) {
        ++avgNumber;
        if (avgNumber >= scalerLiveModeAvg[scalerLiveMode]) {
          avgNumber = 0;
          for (var i = 0; i < scalerNum; ++i) {
            visualScaler[i].removeAt(0);
            visualScaler[i].add(scaler[i]);
          }
        } else {
          for (var i = 0; i < scalerNum; ++i) {
            var lastScaler = visualScaler[i].last;
            var sum = lastScaler * avgNumber + scaler[i];
            visualScaler[i].last = (sum / (avgNumber + 1.0)).round();
          }
        }
      }
      state = 3;
    } catch (e) {
      print("Caught error: $e");
      state = 0;
    }
  }

  Future<void> getVisualScaler({DateTime? date}) async {
    if (scalerMode == 0) {
      await getLiveScaler();
    } else {
      await getHistoryScaler(date!);
    }
  }

  Future<void> getLiveScaler() async {
    var flag = 0;
    for (var i = 0; i < visual.length; ++i) {
      if (!visual[i]) continue;
      flag |= 1 << i;
    }
    final RecentRequest request = RecentRequest(
      type: scalerLiveMode,
      flag: flag
    );
    var rangeIndex = 0;
    var index = 0;
    while (index < scalerNum && !visual[index]) {
      ++index;
    }
    try {
      await for (var response in stub.getScalerRecent(request)) {
        if (rangeIndex >= 120) {
          ++index;
          while (index < scalerNum && !visual[index]) {
            ++index;
          }
          rangeIndex = 0;
        }
        if (index < scalerNum && rangeIndex < 120) {
          visualScaler[index][rangeIndex] = response.value;
          ++rangeIndex;
        }
      }
      avgNumber = 0;
    } catch (e) {
      print("Caught error: $e");
    }
  }

  Future<void> getHistoryScaler(DateTime date) async {
    var flag = 0;
    var visualIndex = [];
    for (var i = 0; i < visual.length; ++i) {
      if (!visual[i]) continue;
      flag |= 1 << i;
      visualIndex.add(i);
    }
    if (flag == 0) return;
    final DateRequest request = DateRequest(
      year: date.year,
      month: date.month,
      day: date.day,
      flag: flag
    );
    try {
      var index = 0;
      var rangeIndex = 0;
      await for (var response in stub.getScalerDate(request)) {
        visualScaler[visualIndex[index]][rangeIndex] = response.value;
        ++rangeIndex;
        if (rangeIndex == visualScaler[visualIndex[index]].length) {
          index++;
          rangeIndex = 0;
        }
      }
    } on GrpcError catch (e) {
      print ("Caught error: $e");
    } catch (e) {
      print("Caught error: $e");
    }
  }

  Future<void> getConfig() async {
    try {
      final Request request = Request(type: 0);
      final response = await stub.getState(request);
      if (response.value != 3) return;
    } catch (e) {
      print("Caught error: $e");
      return;
    }

    final Request request = Request(type: 0);
    List<String> newExpressions = [];
    try {
      await for (var expr in stub.getConfig(request)) {
        newExpressions.add(expr.value);
      }
      configTime = DateTime.parse(newExpressions.first);
      expressions = newExpressions.sublist(1);
    } catch (e) {
      print("Caught error: $e");
    }
  }

  Future<ParseResult> setConfig() async {
    Stream<Expression> convertExpression() async* {
      for (var expr in expressions) {
        yield Expression(value: expr);
      }
    }
    try {
      final result = await stub.setConfig(convertExpression());
      if (
        result.value == 104
        && expressions[result.index].length == result.position
      ) {
        return ParseResult(
          index: result.index,
          status: result.value,
          position: result.position,
          length: 0,
        );
      }
      return ParseResult(
        index: result.index,
        status: result.value,
        position: result.position,
        length: result.length,
      );
    } catch (e) {
      print("Caught error: $e");
      return ParseResult(
        index: -1,
        status: 400,
        position: 0,
        length: 0,
      );
    }
  }
}