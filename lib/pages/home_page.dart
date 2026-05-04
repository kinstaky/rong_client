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
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilledButton(
                  onPressed: () async {
                    await profile.startRun();
                    profile.notifyManual();
                  },
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )
                    ),
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Text(
                    profile.running
                      ? AppLocalizations.of(context)!.stopRun
                      : AppLocalizations.of(context)!.startNewRun,
                  ),
                ),
              ),
              for (var service in profile.services.values)
                ServiceEntry(
                  changePage: changePage,
                  service: service
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: FloatingActionButton(
            onPressed: () => navigateEditServicePage(context),
            tooltip: AppLocalizations.of(context)!.addServiceTooltip,
            child: const Icon(Icons.add),
          ),
        ),
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

// class GroupSelector extends StatelessWidget {
//   const GroupSelector({
//     super.key,
//     required this.service,
//   });

//   final ServiceModel service;

//   @override
//   Widget build(BuildContext context) {
//     return MenuAnchor(
//       builder: (context, controller, child) {
//         return OutlinedButton(
//           onPressed: (){
//             if (controller.isOpen) {
//               controller.close();
//             } else {
//               controller.open();
//             }
//           },
//           style: OutlinedButton.styleFrom(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(5),
//             ),
//           ),
//           child: Text("Group ${service.group}"),
//         );
//       },
//       menuChildren: [
//         for (
//           var i = 0;
//           i < context.read<ServiceManagerModel>().groups.length;
//           ++i
//         )
//           MenuItemButton(
//             onPressed: () {
//               var serviceManager = context.read<ServiceManagerModel>();
//               serviceManager.changeServiceGroup(service.name, i);
//               serviceManager.notifyManual();
//             },
//             child: Text("Group $i"),
//           ),
//         MenuItemButton(
//           onPressed: () {
//             var serviceManager = context.read<ServiceManagerModel>();
//             serviceManager.changeServiceGroup(service.name, -1);
//             serviceManager.notifyManual();
//           },
//           child: Text("New Group"),
//         )
//       ],
//     );
//   }
// }
