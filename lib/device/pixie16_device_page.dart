import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:rong_client/device/pixie16_device.dart';

class Pixie16DevicePage extends StatefulWidget {
  const Pixie16DevicePage({
    super.key,
    required this.changePage,
    required this.device,
  });

  final Function changePage;
  final Pixie16DeviceModel device;

  @override
  State<Pixie16DevicePage> createState() => _Pixie16DevicePageState();
}

class _Pixie16DevicePageState extends State<Pixie16DevicePage> {
  late final TextEditingController runTextController;

  @override
  void initState() {
    super.initState();
    runTextController = TextEditingController(
      text: "${widget.device.run}",
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => widget.changePage(0),
          icon: const Icon(Icons.expand_more),
        ),
        title: Row(
          children: [
            Container(
              margin:  const EdgeInsetsDirectional.symmetric(
                horizontal: 10,
              ),
              child: Text(widget.device.name),
            ),
            Text("${widget.device.address}:${widget.device.port}"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 20.0,
        ),
        child: Row(
          spacing: 20,
          children: [
            Text(
              "Run",
              style: Theme.of(context).textTheme.titleLarge!,
            ),
            SizedBox(
              width: 80,
              child: TextField(
                controller: runTextController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                await widget.device.loadRun();
                runTextController.text = "${widget.device.run}";
              },
              style: buttonStyle,
              child: Text(AppLocalizations.of(context)!.load),
            ),
            OutlinedButton(
              onPressed: (){
                runTextController.text = "";
              },
              style: buttonStyle,
              child: Text(AppLocalizations.of(context)!.clear),
            ),
            FilledButton(
              onPressed: () async {
                final expectRun = runTextController.text.isEmpty
                    ? 0
                    : int.parse(runTextController.text);
                await widget.device.changeRun(expectRun);
                if (widget.device.run != expectRun) {
                  final snackBar = SnackBar(
                    behavior: SnackBarBehavior.floating,
                    width: 800,
                    content: const Text("Change run number failed."),
                    duration: const Duration(seconds: 3),
                    action: SnackBarAction(
                      label: context.mounted
                        ? AppLocalizations.of(context)!.close
                        : "Close",
                      onPressed: () {},
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              },
              style: buttonStyle,
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }
}