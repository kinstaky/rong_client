import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

import 'manager/app_manager.dart';
import 'manager/settings.dart';
import 'pages/home_page.dart';
import 'pages/mztio_service_page.dart';
import 'pages/settings_page.dart';
import 'service/service.dart';
import 'service/mztio_service.dart';

final manager = AppManager();

void main() async {
  await manager.load();
  runApp(const Client());
}


class Client extends StatelessWidget {
  const Client({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => manager),
        ChangeNotifierProvider(create: (context) => manager.settings),
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

  void changePage(int value) {
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
        var manager = context.watch<AppManager>();
        var profile = manager.profiles[manager.currentProfile];
        var service = profile.services[profile.selectedService];
        if (service == null) {
          page = const Scaffold();
        } else if (service.type == ServiceType.mztio) {
          page = MztioServicePage(
            changePage: changePage,
            service: service as MztioServiceModel,
          );
        } else if (service.type == ServiceType.pixie16) {
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
                  label: Text('Service'),
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
