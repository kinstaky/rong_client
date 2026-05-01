import 'package:flutter/material.dart';
import '../service/service.dart';
import '../l10n/app_localizations.dart';


class EditServicePage extends StatefulWidget {
  const EditServicePage({
    super.key,
    this.service,
  });

  final Map<String, dynamic>? service;

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {

  _EditServicePageState();

  ServiceType? selectedType = ServiceType.mztio;

  @override
  void initState() {
    super.initState();
    textController["name"] = TextEditingController(
      text: widget.service?["name"],
    );
    textController["ip"] = TextEditingController(
      text: widget.service?["ip"],
    );
    textController["port"] = TextEditingController(
      text: widget.service?["port"],
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
      "type": AppLocalizations.of(context)!.serviceType,
      "name": AppLocalizations.of(context)!.name,
      "ip": AppLocalizations.of(context)!.ip,
      "port": AppLocalizations.of(context)!.port,
    };
    final hintPrefix = AppLocalizations.of(context)!.serviceInputHintPrefix;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.service == null
            ? AppLocalizations.of(context)!.newServiceTitle
            : AppLocalizations.of(context)!.editServiceTitle,
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
            child: RadioGroup<ServiceType>(
              groupValue: selectedType,
              onChanged: (ServiceType? value) {
                setState(() {
                  selectedType = value;
                });
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    width: 130,
                    child: Text(localNames["type"]!),
                  ),
                  SizedBox(
                    width: 200,
                    child: const ListTile(
                      title: Text("MZTIO"),
                      leading: Radio(value: ServiceType.mztio),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: const ListTile(
                      title: Text("Pixie16"),
                      leading: Radio(value: ServiceType.pixie16),
                    ),
                  ),
                ],
              )
            ),
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
                    width: 130,
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
                Navigator.pop(context, {
                  "name": textController["name"]!.text,
                  "ip": textController["ip"]!.text,
                  "port": textController["port"]!.text,
                  "type": selectedType ?? ServiceType.other,
                });
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          )
        ],
      )
    );
  }
}