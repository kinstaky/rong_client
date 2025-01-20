import 'package:flutter/material.dart';
import 'package:rong_client/device/device.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class EditDevicePage extends StatefulWidget {
  const EditDevicePage({
    super.key,
    this.device,
  });

  final DeviceModel? device;

  @override
  State<EditDevicePage> createState() => _EditDevicePageState();
}

class _EditDevicePageState extends State<EditDevicePage> {

  _EditDevicePageState();

  DeviceType? selectedType = DeviceType.mztio;

  @override
  void initState() {
    super.initState();
    textController["name"] = TextEditingController(
      text: widget.device?.name,
    );
    textController["ip"] = TextEditingController(
      text: widget.device?.address,
    );
    textController["port"] = TextEditingController(
      text: widget.device?.port,
    );
  }

  @override
  void dispose() {
    for (var controller in textController.values) {
      controller.dispose();
    }
    super.dispose();
  }

  static const textFieldName = ["name", "ip", "port"];
  final Map<String, TextEditingController> textController = {};


  @override
  Widget build(BuildContext context) {
    final localNames = {
      "type": AppLocalizations.of(context)!.deviceType,
      "name": AppLocalizations.of(context)!.name,
      "ip": AppLocalizations.of(context)!.ip,
      "port": AppLocalizations.of(context)!.port,
    };
    final hintPrefix = AppLocalizations.of(context)!.deviceInputHintPrefix;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.device == null
            ? AppLocalizations.of(context)!.newDeviceTitle
            : AppLocalizations.of(context)!.editDeviceTitle,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  width: 100,
                  child: Text(localNames["type"]!),
                ),
                SizedBox(
                  width: 160,
                  child: RadioListTile<DeviceType>(
                    title: const Text("MZTIO"),
                    value: DeviceType.mztio,
                    groupValue: selectedType,
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: RadioListTile<DeviceType>(
                    title: const Text("Pixie16"),
                    value: DeviceType.pixie16,
                    groupValue: selectedType,
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                ),
              ],
            )
          ),
          for (var name in textFieldName)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    width: 100,
                    child: Text(localNames[name]!),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: textController[name],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "$hintPrefix${localNames[name]}",
                      ),
                    )
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 30,
            ),
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context, DefaultDeviceModel(
                  name: textController["name"]!.text,
                  address: textController["ip"]!.text,
                  port: textController["port"]!.text,
                  type: selectedType ?? DeviceType.other,
                  group: 0
                ));
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          )
        ],
      )
    );
  }
}