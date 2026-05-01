import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../service/pixie16_service.dart';

class Pixie16ServicePage extends StatefulWidget {
  const Pixie16ServicePage({
    super.key,
    required this.changePage,
    required this.service,
  });

  final Function changePage;
  final Pixie16ServiceModel service;

  @override
  State<Pixie16ServicePage> createState() => _Pixie16ServicePageState();
}

class _Pixie16ServicePageState extends State<Pixie16ServicePage> {
  late final TextEditingController runTextController;

  @override
  void initState() {
    super.initState();
    runTextController = TextEditingController(
      text: "${widget.service.run}",
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
              child: Text(widget.service.name),
            ),
            Text("${widget.service.ip}:${widget.service.port}"),
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
                await widget.service.loadRun();
                runTextController.text = "${widget.service.run}";
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
                await widget.service.changeRun(expectRun);
                if (widget.service.run != expectRun) {
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