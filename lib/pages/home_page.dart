import 'package:easy_daq_client/manager/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../service/service.dart';
import 'edit_service_page.dart';

Future<void> navigateEditServicePage(
  BuildContext context,
  {Map<String, dynamic>? service}
) async {
  final newService = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditServicePage(service: service),
    ),
  );

  // copy from example
  if (!context.mounted) return;

  // no change
  if (newService == null) return;

  // read service map
  final profile = context.read<ProfileModel>();

  // add service
  if (service == null) {
    profile.addService(newService);
  } else {
    profile.editService(newService);
  }
}


class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.changePage,
  });

  final Function changePage;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileModel>();

    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var service in profile.services.values)
              ServiceEntry(
                changePage: changePage,
                service: service
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: FloatingActionButton(
            onPressed: () => navigateEditServicePage(context),
            tooltip: AppLocalizations.of(context)!.addServiceTooltip,
            child: const Icon(Icons.add),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: SizedBox(
              width: 200,
              height: 60,
              child: FloatingActionButton(
                onPressed: (profile.allRunning != profile.allStopeed)
                  ? () async {
                    await profile.startRun();
                    profile.notifyManual();
                  }
                  : null,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                foregroundColor: (profile.allRunning != profile.allStopeed)
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.onSecondary.withAlpha(100),
                backgroundColor: (profile.allRunning != profile.allStopeed)
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.secondary.withAlpha(100),
                tooltip: (profile.allRunning != profile.allStopeed)
                  ? profile.allRunning
                    ? AppLocalizations.of(context)!.stopRun
                    : AppLocalizations.of(context)!.startNewRun
                  : "",
                child: Text(
                  profile.allRunning
                    ? AppLocalizations.of(context)!.stopRun
                    : AppLocalizations.of(context)!.startNewRun,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}


class ServiceEntry extends StatelessWidget {
  const ServiceEntry({
    super.key,
    required this.changePage,
    required this.service
  });

  final Function changePage;
  final ServiceModel service;

  Future<void> confirmDeleteServiceDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.deleteServiceTitle,
          style: Theme.of(context).textTheme.headlineMedium!,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.titleLarge,
            ),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.titleLarge,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      )
    );
    if (result != null && result && context.mounted) {
      final profile = context.read<ProfileModel>();
      profile.deleteService(service.name);
    }
  }

  Future<void> confirmStartRunServiceDialog(BuildContext context, ServiceModel service) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          service.state == 2
          ? AppLocalizations.of(context)!.stopRun
          : AppLocalizations.of(context)!.startNewRun,
          style: Theme.of(context).textTheme.headlineMedium!,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.titleLarge,
            ),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.titleLarge,
            ),
            child: service.state == 2
              ? Text(AppLocalizations.of(context)!.stopRun)
              : Text(AppLocalizations.of(context)!.startNewRun),
          ),
        ],
      )
    );
    if (result != null && result && context.mounted) {
      service.startRun();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const statusColor = [
      Colors.grey,
      Colors.red,
      Colors.orange,
      Colors.green,
    ];

    return ListTile(
      leading: Icon(
        Icons.circle,
        color: statusColor[service.state],
      ),
      title: Row(
        children: [
          SizedBox(
            width: 270,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: theme.textTheme.headlineMedium,
                ),
                Text(
                    "${service.type == ServiceType.mztio ? 'MZTIO' : 'Pixie16'}"
                    "  ${service.ip}:${service.port}",
                    style: theme.textTheme.titleMedium!.copyWith(
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
					Padding(
						padding: const EdgeInsets.symmetric(
							vertical: 0.0,
							horizontal: 50.0,
						),
						child: SizedBox(
              width: 100,
              child: Text(
                "Run ${service.run}",
                style: Theme.of(context).textTheme.headlineSmall!,
              ),
            ),
					),
          // GroupSelector(service: service),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh),
            iconSize: 36,
            tooltip: AppLocalizations.of(context)!.refreshTooltip,
            onPressed: () {
              service.errorConnect = 0;
              service.refreshState();
            }
          ),
          IconButton(
            onPressed: () => confirmStartRunServiceDialog(context, service),
            iconSize: 36,
            icon: service.state == 2 ? Icon(Icons.stop) : Icon(Icons.play_arrow),
            tooltip: service.state == 2
              ? AppLocalizations.of(context)!.stopRun
              : AppLocalizations.of(context)!.startNewRun
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            iconSize: 36,
            tooltip: AppLocalizations.of(context)!.editServiceTooltip,
            onPressed: () => navigateEditServicePage(
              context,
              service: {
                "name": service.name,
                "ip": service.ip,
                "port": service.port,
                "type": service.type,
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            iconSize: 36,
            tooltip: AppLocalizations.of(context)!.delete,
            onPressed: () => confirmDeleteServiceDialog(context),
          ),
        ],
      ),
      onTap: () {
        final profile = context.read<ProfileModel>();
        profile.selectedService = service.name;
        changePage(1);
      },
      enabled: service.state != 0,
    );
  }
}