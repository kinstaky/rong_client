import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rong_client/device/device.dart';
import 'package:rong_client/device/device_manager.dart';
import 'package:rong_client/edit_device_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


Future<void> navigateEditDevicePage(
  BuildContext context,
  {DeviceModel? device}
) async {
  final newDevice = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditDevicePage(device: device),
    ),
  );

  // copy from example
  if (!context.mounted) return;

  // no change
  if (newDevice == null) return;

  // read device map
  var deviceManager = context.read<DeviceManagerModel>();

  // add device
  if (device == null) {
    deviceManager.addDevice(newDevice);
  } else {
    deviceManager.editDevice(newDevice);
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
    var deviceManager = context.watch<DeviceManagerModel>();

    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        ListView(
          children: [
            for (var group in deviceManager.groups)
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FilledButton(
                        onPressed: () async {
                          await group.startRun();
                          deviceManager.notifyManual();
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
                          group.running
                            ? AppLocalizations.of(context)!.stopRun
                            : AppLocalizations.of(context)!.startNewRun,
                        ),
                      ),
                    ),
                    for (var device in group.devices)
                      DeviceEntry(
                        changePage: changePage,
                        device: device
                      ),
                  ],
                ),
              )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: FloatingActionButton(
            onPressed: () => navigateEditDevicePage(context),
            tooltip: AppLocalizations.of(context)!.addDeviceTooltip,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}


class DeviceEntry extends StatelessWidget {
  const DeviceEntry({
    super.key,
    required this.changePage,
    required this.device
  });

  final Function changePage;
  final DeviceModel device;

  Future<void> confirmDeleteDeviceDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.deleteDeviceTitle,
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
      var deviceManager = context.read<DeviceManagerModel>();
      deviceManager.deleteDevice(device.name);
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
        color: statusColor[device.state],
      ),
      title: Row(
        children: [
          SizedBox(
            width: 270,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: theme.textTheme.headlineMedium,
                ),
                Text(
                    "${device.type == DeviceType.mztio ? 'MZTIO' : 'Pixie16'}"
                    "  ${device.address}:${device.port}",
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
                "Run ${device.run}",
                style: Theme.of(context).textTheme.headlineSmall!,
              ),
            ),
					),
          GroupSelector(device: device),
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
              device.errorConnect = 0;
              device.refreshState();
            }
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            iconSize: 36,
            tooltip: AppLocalizations.of(context)!.editDeviceTooltip,
            onPressed: () => navigateEditDevicePage(
              context,
              device: device,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            iconSize: 36,
            tooltip: AppLocalizations.of(context)!.delete,
            onPressed: () => confirmDeleteDeviceDialog(context),
          ),
        ],
      ),
      onTap: () {
        var deviceManager = context.read<DeviceManagerModel>();
        deviceManager.selectedDevice = device.name;
        changePage(1);
      },
      enabled: device.state != 0,
    );
  }
}

class GroupSelector extends StatelessWidget {
  const GroupSelector({
    super.key,
    required this.device,
  });

  final DeviceModel device;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) {
        return OutlinedButton(
          onPressed: (){
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text("Group ${device.group}"),
        );
      },
      menuChildren: [
        for (
          var i = 0;
          i < context.read<DeviceManagerModel>().groups.length;
          ++i
        )
          MenuItemButton(
            onPressed: () {
              var deviceManager = context.read<DeviceManagerModel>();
              deviceManager.changeDeviceGroup(device.name, i);
              deviceManager.notifyManual();
            },
            child: Text("Group $i"),
          ),
        MenuItemButton(
          onPressed: () {
            var deviceManager = context.read<DeviceManagerModel>();
            deviceManager.changeDeviceGroup(device.name, -1);
            deviceManager.notifyManual();
          },
          child: Text("New Group"),
        )
      ],
    );
  }
}
