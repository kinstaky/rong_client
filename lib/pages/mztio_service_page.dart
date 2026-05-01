import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

import '../service/mztio_service.dart';
import '../l10n/app_localizations.dart';

const List<Color> defaultLineColors = [
  Color(0xFF6E44FF),
  Color(0xFFFF1053),
  Color(0xFFFE6D73),
  Color(0xFF72DDF7),
  Color(0xFFFFACE4),
  Color(0xFF43A047),
  Color(0xFFECA400),
  Color(0xFFA76571),
  Color(0xFF17C3B2),
  Color(0xFFCE1483),
  Color(0xFF04E824),
  Color(0xFFC6CA53),
  Color(0xFFFF1B1C),
  Color(0xFF275DAD),
  Color(0xFF70B77E),
  Color(0xFF961D4E),
  Color(0xFFFFC53A),
  Color(0xFFAB87FF),
  Color(0xFFF05D23),
  Color(0xFFF08080),
  Color(0xFF227C9D),
  Color(0xFFB26700),
  Color(0xFFFF7F11),
  Color(0xFF04724D),
  Color(0xFFC5D86D),
  Color(0xFF009688),
  Color(0xFFDB5461),
  Color(0xFF44FFD1),
  Color(0xFFD14081),
  Color(0xFF006992),
  Color(0xFFAEADF0),
  Color(0xFFBDBF09),
];


class MztioServicePage extends StatelessWidget {

  const MztioServicePage({
    super.key,
    required this.changePage,
    required this.service,
  });

  final Function changePage;
  final MztioServiceModel service;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => changePage(0),
            icon: const Icon(Icons.expand_more)
          ),
          title: Row(
            children: [
              Container(
                margin: const EdgeInsetsDirectional.symmetric(
                  horizontal: 10,
                ),
                child: Text(service.name)
              ),
              Text("${service.ip}:${service.port}"),
            ],
          ),
          bottom: TabBar(
            tabs:  [
              Tab(text: AppLocalizations.of(context)!.scaler),
              Tab(text: AppLocalizations.of(context)!.config),
              Tab(text: AppLocalizations.of(context)!.scalerNames)
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: ScalerTab(
                restorationId: "scaler_tab",
                service: service,
              ),
            ),
            ConfigTab(service: service),
            ScalerNamesTab(service: service),
          ],
        ),
      ),
    );
  }
}

class ScalerNamesTab extends StatefulWidget {
  const ScalerNamesTab({
    super.key,
    required this.service,
  });

  final MztioServiceModel service;

  @override
  State<ScalerNamesTab> createState() => _ScalerNamesTabState();
}

class _ScalerNamesTabState extends State<ScalerNamesTab> {
  final buttonStyle = OutlinedButton.styleFrom(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
  );

  late final List<TextEditingController> textControllers;


  @override
  void initState() {
    super.initState();
    textControllers = List.generate(
      widget.service.scalerNames.length,
      (index) => TextEditingController(
        text: widget.service.scalerNames[index],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      for (var i = 0; i < widget.service.scalerNames.length; i++) {
                        textControllers[i].text = widget.service.scalerNames[i];
                      }
                    },
                    style: buttonStyle,
                    child: Text(AppLocalizations.of(context)!.load),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 0,
                  ),
                  child: OutlinedButton(
                    onPressed: (){
                      for (var i = 0; i < widget.service.scalerNames.length; i++) {
                        textControllers[i].text = "$i";
                      }
                    },
                    style: buttonStyle,
                    child: Text(AppLocalizations.of(context)!.reset),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                  child: FilledButton(
                    onPressed: () {
                      for (var i = 0; i < widget.service.scalerNames.length; ++i) {
                        widget.service.scalerNames[i] = textControllers[i].text;
                      }
                      widget.service.saveScalerNames();
                    },
                    style: buttonStyle,
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20, 20, 0, 5
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.service.scalerNames.mapIndexed(
                  (index, value) => SizedBox(
                    width: 132,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            index < 10 ? "  $index" : "$index",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: textControllers[index],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfigTab extends StatefulWidget {
  const ConfigTab({
    super.key,
    required this.service,
  });

  final MztioServiceModel service;

  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {

  _ConfigTabState();

  late final TextEditingController textController;
	late final TextEditingController runTextController;

  bool validParseResult(ParseResult result) {
    if (result.status == 201 || result.status == 208 || result.status == 300) {
      return false;
    }
    if (result.index < 0) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(
      text: widget.service.expressions.join("\n"),
    );
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
    final textStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: 18.0,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                  child: OutlinedButton(
                    onPressed: () async {
                      await widget.service.getConfig();
                      textController.text =
                        widget.service.expressions.join("\n");
                    },
                    style: buttonStyle,
					          child: Text(AppLocalizations.of(context)!.load),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 0,
                  ),
                  child: OutlinedButton(
                    onPressed: (){
                      textController.text = "";
                    },
                    style: buttonStyle,
                    child: Text(AppLocalizations.of(context)!.clear),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                  child: FilledButton(
                    onPressed: () async {
                      var expressions = textController.text.split("\n");
                      widget.service.expressions = expressions;
                      var result = await widget.service.setConfig();
                      if (result.status != 0) {
                        final snackBar = SnackBar(
                          behavior: SnackBarBehavior.floating,
                          width: 800,
                          content: RichText(
														text: TextSpan(
															text: result.message(),
															style: textStyle.copyWith(
																color: context.mounted
																	? Theme.of(context).colorScheme.surface
																	: Colors.black,
															),
															children: <TextSpan>[
																TextSpan(
																	text: validParseResult(result)
																		? expressions[result.index].substring(
																			0,
																			result.position
																		)
																		: "",
																),
																TextSpan(
																	text: validParseResult(result)
																		? expressions[result.index].substring(
																			result.position,
																			result.position + result.length
																		)
																		: "",
																	style: textStyle.copyWith(
																		color: Colors.red,
																	),
																),
																TextSpan(
																	text: validParseResult(result)
																		? expressions[result.index].substring(
																			result.position + result.length,
																			expressions[result.index].length
																		)
																		: "",
																),
															],
                            ),
                          ),
                          duration: const Duration(seconds: 5),
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
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 5.0),
              child: Text(
                "${AppLocalizations.of(context)!.lastConfigHint}"
								"${widget.service.configTime.toString().substring(0, 19)}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20.0, 0.0, 20.0, 15.0
              ),
              child: TextField(
                controller: textController,
                keyboardType: TextInputType.multiline,
                maxLines: 15,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Divider(),
						Padding(
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
          ],
        ),
      ),
    );
  }
}


class ScalerTab extends StatefulWidget {
  const ScalerTab({
    super.key,
    this.restorationId,
    required this.service,
  });

  // service
  final MztioServiceModel service;

  // restoration id
  final String? restorationId;

  @override
  State<ScalerTab> createState() => _ScalerTabState();
}

class _ScalerTabState extends State<ScalerTab> with RestorationMixin {
  ScalerMode scalerMode = ScalerMode.modeLive;
  final RestorableDateTime selectedDate = RestorableDateTime(DateTime.now());

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(selectedDate, 'selected_date');
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        30, 0, 0, 0
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: SizedBox(
                  width: 250,
                  child: SegmentedButton<ScalerMode>(
                    segments: <ButtonSegment<ScalerMode>>[
                      ButtonSegment<ScalerMode>(
                        value: ScalerMode.modeLive,
                        label: Text(AppLocalizations.of(context)!.realTimeSelection),
                      ),
                      ButtonSegment<ScalerMode>(
                        value: ScalerMode.modeHistory,
                        label: Text(AppLocalizations.of(context)!.historySelection),
                      ),
                    ],
                    selected: <ScalerMode>{scalerMode},
                    onSelectionChanged: (Set<ScalerMode> newSelection) {
                      setState(() {
                        scalerMode = newSelection.first;
                      });
                      if (scalerMode == ScalerMode.modeLive) {
                        widget.service.scalerMode = 0;
                        widget.service.getLiveScaler();
                      } else if (scalerMode == ScalerMode.modeHistory) {
                        widget.service.scalerMode = 1;
                        widget.service.getHistoryScaler(selectedDate.value);
                      }
                    },
                  ),
                ),
              ),
              scalerMode == ScalerMode.modeLive
                ? LiveModeSelector(
                  selectedMode: widget.service.scalerLiveMode,
                  service: widget.service,
                )
                : HistoryDateSelector(
                  restorationId: "history",
                  selectedDate: selectedDate,
                  service: widget.service,
                ),
            ],
          ),
          ScalerChart(
            service: widget.service,
          ),
          ScalerLiveText(
            service: widget.service,
          ),
        ],
      ),
    );
  }
}


class LiveModeSelector extends StatefulWidget {
  const LiveModeSelector({
    super.key,
    required this.selectedMode,
    required this.service,
  });

  final int selectedMode;
  final MztioServiceModel service;

  @override
  State<LiveModeSelector> createState() => _LiveModeSelectorState();
}

class _LiveModeSelectorState extends State<LiveModeSelector> {
  int selectedMode = 0;

  @override
  void initState() {
    super.initState();
    selectedMode = widget.selectedMode;
  }

  @override
  Widget build(BuildContext context) {
	var localScalerLiveModeName = [
		AppLocalizations.of(context)!.liveModeName2m,
    AppLocalizations.of(context)!.liveModeName20m,
    AppLocalizations.of(context)!.liveModeName2h,
    AppLocalizations.of(context)!.liveModeName24h,
	];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: MenuAnchor(
        builder: (BuildContext context, MenuController controller, Widget? child) {
          return FilledButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            style: FilledButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            child: Text(localScalerLiveModeName[selectedMode]),
          );
        },
        menuChildren: List<MenuItemButton>.generate(
          ScalerLiveMode.values.length,
          (int index) => MenuItemButton(
            onPressed: () {
              widget.service.scalerLiveMode = index;
              widget.service.getLiveScaler();
              setState(() => selectedMode = index);
            },
            child: Text(localScalerLiveModeName[index]),
          )
        )
      ),
    );
  }
}

class HistoryDateSelector extends StatefulWidget {
  const HistoryDateSelector({
    super.key,
    this.restorationId,
    required this.selectedDate,
    required this.service,
  });

  final String? restorationId;
  final RestorableDateTime selectedDate;
  final MztioServiceModel service;

  @override
  State<HistoryDateSelector> createState() => _HistoryDateSelectorState();
}

class _HistoryDateSelectorState
  extends State<HistoryDateSelector>
  with RestorationMixin {

  @override
  String? get restorationId => widget.restorationId;


  late final RestorableRouteFuture<DateTime?> _restorableRouteFuture =
    RestorableRouteFuture<DateTime?>(
      onComplete: _selectDate,
      onPresent: (NavigatorState navigator, Object? arguments) {
        return navigator.restorablePush(
          _datePickerRoute,
          arguments: widget.selectedDate.value.millisecondsSinceEpoch,
        );
      }
    );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments
  ) {
    return DialogRoute(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: "history_date_picker_dialog",
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2024, 9, 1),
          lastDate: DateTime.now(),
        );
      }
    );
  }


  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        widget.selectedDate.value = newSelectedDate;
        widget.service.getHistoryScaler(newSelectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: FilledButton(
        onPressed: () {
          _restorableRouteFuture.present();
        },
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        child: Text(
          "${widget.selectedDate.value.year}"
          "-${widget.selectedDate.value.month}"
          "-${widget.selectedDate.value.day}"
        ),
      ),
    );
  }
}


class ScalerChart extends StatelessWidget {
  const ScalerChart({
    super.key,
    required this.service,
  });

  final MztioServiceModel service;

  List<LineChartBarData> scalerLineData(List<List<int>> scalers, List<bool> show) {
    List<LineChartBarData> result = [];
    for (var i = 0; i < scalerNum; ++i) {
      if (!show[i]) continue;
      result.add(LineChartBarData(
        isCurved: false,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        color: defaultLineColors[i],
        spots: scalers[i].mapIndexed(
          (index, value) => FlSpot(index.toDouble(), value.toDouble())
        ).toList(),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 30, 30),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF50E4FF).withAlpha(51),
                  width: 4
                ),
                left: BorderSide(
                  color: const Color(0xFF50E4FF).withAlpha(51),
                  width: 4
                ),
                top: const BorderSide(color: Colors.transparent),
                right: const BorderSide(color: Colors.transparent),
              ),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: 12,
                  maxIncluded: true,
                  getTitlesWidget: (value, meta) {
                    late final String text;
                    if (ScalerMode.values[service.scalerMode] == ScalerMode.modeLive) {
                      final time = DateTime.now().add(Duration(
                        seconds: (value.toInt() - 120) * scalerLiveModeAvg[service.scalerLiveMode]
                      ));
                      if (ScalerLiveMode.values[service.scalerLiveMode] == ScalerLiveMode.mode2m) {
                        text = "${time.hour}"
                          ":${time.minute.toString().padLeft(2, '0')}"
                          ":${time.second.toString().padLeft(2, '0')}";
                      } else {
                        text = "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
                      }
                    } else {
                      final minute = (value.toInt() * 12) % 60;
                      final hour = (value / 5).toInt();
                      text = "$hour:$minute";
                    }
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(text),
                    );
                  },
                )
              )
            ),
            lineBarsData: scalerLineData(
              service.visualScaler,
              service.visual
            ),
            minX: 0,
            minY: 0,
          )
        ),
      ),
    );
  }
}


class ScalerLiveText extends StatelessWidget {
  const ScalerLiveText({
    super.key,
    required this.service,
  });

  final MztioServiceModel service;

  List<SizedBox> buildText(BuildContext context, List<String> name, List<int> value) {
    List<SizedBox> result = [];
    for (var index = 0; index < name.length; ++index) {
      result.add(
        SizedBox(
          width: 120,
          child: TextButton(
            onPressed: () {
              service.visual[index] = !service.visual[index];
              service.getLiveScaler();
            },
            style: TextButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              alignment: Alignment.centerLeft,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${name[index]}: ${value[index]}",
                  style: service.visual[index]
                    ? Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: defaultLineColors[index]
                    )
                    : Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: buildText(context, service.scalerNames, service.scaler),
    );
  }
}

