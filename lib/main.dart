import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rong_client/settings.dart';
import 'package:rong_client/home_page.dart';
import 'package:rong_client/settings_page.dart';
import 'package:rong_client/device/device.dart';
import 'package:rong_client/device/mztio_device.dart';
import 'package:rong_client/device/device_manager.dart';
import 'package:rong_client/device/mztio_device_page.dart';

// final lineColors = [];
final deviceManager = DeviceManagerModel();
final settingsModel = SettingsModel();

void main() async {
  await deviceManager.init();
  await settingsModel.init();
  runApp(const Client());
}


class Client extends StatelessWidget {
  const Client({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => deviceManager),
        ChangeNotifierProvider(create: (context) => settingsModel),
      ],
      builder: (context, child) {
        return MaterialApp(
          title: "easy config logic client",
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          supportedLocales: const [
            Locale("en"), // English
            Locale("zh"), // Chinese
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: context.watch<SettingsModel>().color,
              brightness: context.watch<SettingsModel>().brightness,
            ),
            fontFamily: context.watch<SettingsModel>().locale
              == Locale("zh") ? "NotoSansSC" : "Roboto",
          ),
          restorationScopeId: "app",
          locale: context.watch<SettingsModel>().locale,
          home: const ClientPage(),
        );
      }
    );
  }
}


class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}


class _ClientPageState extends State<ClientPage> {
  var selectedPageIndex = 0;

  void changePage(value) {
    setState(() {
      selectedPageIndex = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedPageIndex) {
      case 0:
        page = HomePage(
          changePage: changePage,
        );
        break;
      case 1:
        var deviceManager = context.watch<DeviceManagerModel>();
        var device = deviceManager.devices[deviceManager.selectedDevice];
        if (device == null) {
          page = const Scaffold();
        } else if (device.type == DeviceType.mztio) {
          page = MztioDevicePage(
            changePage: changePage,
            device: device as MztioDeviceModel,
          );
        } else if (device.type == DeviceType.pixie16) {
          page = const Placeholder();
        } else {
          page = const Scaffold();
        }
        break;
      case 2:
        page = SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedPageIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    size: 48,
                  ),
                  selectedIcon: Icon(
                    Icons.home,
                    size: 48,
                  ),
                  label: Text('Home')
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Icons.dns_outlined,
                    size: 48,
                  ),
                  selectedIcon: Icon(
                    Icons.dns,
                    size: 48,
                  ),
                  label: Text('Device'),
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Icons.settings_outlined,
                    size: 48,
                  ),
                  selectedIcon: Icon(
                    Icons.settings,
                    size: 48,
                  ),
                  label: Text("Preferences"),
                ),
              ],
              selectedIndex: selectedPageIndex,
              onDestinationSelected: changePage,
            )
          ),
          Expanded(
            child: page,
          ),
        ],
      ),
    );
  }
}
