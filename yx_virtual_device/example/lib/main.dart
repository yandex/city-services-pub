import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yx_virtual_device/yx_virtual_device.dart';
import 'package:yx_virtual_device/virtual_device/devtools/bindings.dart';

void main() {
  // Called before [run App] to replace bindings.
  // It is good not to use it in the product assembly.
  if (kProfileMode || kDebugMode) {
    VirtualDeviceDevtools.setup();
  }
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  DeviceInfo? _currentDevice;

  List<DeviceInfo?> get _allDevices => [
        null,
        ...Devices.ios.all,
        ...Devices.android.all,
        ...Devices.standard.all,
      ];

  void _setDevice(DeviceInfo? device) {
    setState(() {
      _currentDevice = device;
      VirtualDeviceDevtools.setDevice(device);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_currentDevice?.name ?? 'Real Device'),
          centerTitle: true,
          actions: [
            if (_currentDevice != null)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _setDevice(null),
                tooltip: 'Reset to real device',
              ),
          ],
        ),
        drawer: _DeviceDrawer(
          devices: _allDevices,
          currentDevice: _currentDevice,
          onDeviceSelected: _setDevice,
        ),
        body: SafeArea(
          child: _DeviceInfoScreen(device: _currentDevice),
        ),
        floatingActionButton: _QuickSwitchFAB(
          devices: _allDevices,
          currentDevice: _currentDevice,
          onDeviceSelected: _setDevice,
        ),
      ),
    );
  }
}

class _DeviceDrawer extends StatelessWidget {
  const _DeviceDrawer({
    required this.devices,
    required this.currentDevice,
    required this.onDeviceSelected,
  });

  final List<DeviceInfo?> devices;
  final DeviceInfo? currentDevice;
  final ValueChanged<DeviceInfo?> onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.devices, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Virtual Devices',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Select a device to emulate',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // Real Device
          SliverToBoxAdapter(
            child: _DeviceListTile(
              device: null,
              isSelected: currentDevice == null,
              onTap: () {
                onDeviceSelected(null);
                Navigator.pop(context);
              },
            ),
          ),

          const SliverToBoxAdapter(child: Divider()),

          // iOS Devices
          _DeviceSection(
            title: 'iOS',
            devices: Devices.ios.all,
            currentDevice: currentDevice,
            onDeviceSelected: (device) {
              onDeviceSelected(device);
              Navigator.pop(context);
            },
          ),

          // Android Devices
          _DeviceSection(
            title: 'Android',
            devices: Devices.android.all,
            currentDevice: currentDevice,
            onDeviceSelected: (device) {
              onDeviceSelected(device);
              Navigator.pop(context);
            },
          ),

          // Standard Devices
          _DeviceSection(
            title: 'Standard',
            devices: Devices.standard.all,
            currentDevice: currentDevice,
            onDeviceSelected: (device) {
              onDeviceSelected(device);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _DeviceSection extends StatelessWidget {
  const _DeviceSection({
    required this.title,
    required this.devices,
    required this.currentDevice,
    required this.onDeviceSelected,
  });

  final String title;
  final List<DeviceInfo> devices;
  final DeviceInfo? currentDevice;
  final ValueChanged<DeviceInfo> onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            );
          }

          final device = devices[index - 1];
          return _DeviceListTile(
            device: device,
            isSelected: currentDevice?.name == device.name,
            onTap: () => onDeviceSelected(device),
          );
        },
        childCount: devices.length + 1,
      ),
    );
  }
}

class _DeviceListTile extends StatelessWidget {
  const _DeviceListTile({
    required this.device,
    required this.isSelected,
    required this.onTap,
  });

  final DeviceInfo? device;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon {
    if (device == null) return Icons.phone_android;

    final name = device!.name.toLowerCase();
    if (name.contains('iphone')) return Icons.phone_iphone;
    if (name.contains('ipad') || name.contains('tablet')) {
      return Icons.tablet_mac;
    }
    if (name.contains('desktop')) return Icons.desktop_windows;
    return Icons.phone_android;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        _icon,
        color: isSelected ? colorScheme.primary : null,
      ),
      title: Text(device?.name ?? 'Real Device'),
      subtitle: device != null
          ? Text(
              '${device!.screenSize.width.toInt()}×${device!.screenSize.height.toInt()} @${device!.pixelRatio}x',
              style: TextStyle(
                color: isSelected ? colorScheme.primary : null,
              ),
            )
          : const Text('Use actual device dimensions'),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      onTap: onTap,
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
    );
  }
}

class _DeviceInfoScreen extends StatelessWidget {
  const _DeviceInfoScreen({required this.device});

  final DeviceInfo? device;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final view = View.of(context);
        final binding = VirtualWidgetsFlutterBinding.virtualBinding;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Device Card
              _InfoCard(
                title: 'Current Device',
                icon: Icons.devices,
                color: Colors.blue,
                child: Column(
                  children: [
                    _InfoRow('Name', device?.name ?? 'Real Device'),
                    if (device != null) ...[
                      _InfoRow(
                        'Screen Size',
                        '${device!.screenSize.width.toInt()} × ${device!.screenSize.height.toInt()}',
                      ),
                      _InfoRow('Pixel Ratio', '${device!.pixelRatio}x'),
                      _InfoRow('Platform', device!.identifier.platform.name),
                      _InfoRow('Type', device!.identifier.type.name),
                      _InfoRow(
                        'Safe Areas',
                        _formatEdgeInsets(device!.safeAreas),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Layout Constraints
              _InfoCard(
                title: 'Layout Constraints',
                icon: Icons.aspect_ratio,
                color: Colors.green,
                child: Column(
                  children: [
                    _InfoRow(
                      'Max Width',
                      constraints.maxWidth.toStringAsFixed(1),
                    ),
                    _InfoRow(
                      'Max Height',
                      constraints.maxHeight.toStringAsFixed(1),
                    ),
                    _InfoRow(
                      'Aspect Ratio',
                      (constraints.maxWidth / constraints.maxHeight)
                          .toStringAsFixed(2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // MediaQuery
              _InfoCard(
                title: 'MediaQuery',
                icon: Icons.screen_search_desktop_outlined,
                color: Colors.orange,
                child: Column(
                  children: [
                    _InfoRow(
                      'Size',
                      '${mediaQuery.size.width.toStringAsFixed(1)} × ${mediaQuery.size.height.toStringAsFixed(1)}',
                    ),
                    _InfoRow('Pixel Ratio', '${mediaQuery.devicePixelRatio}x'),
                    _InfoRow('Padding', _formatEdgeInsets(mediaQuery.padding)),
                    _InfoRow(
                      'View Insets',
                      _formatEdgeInsets(mediaQuery.viewInsets),
                    ),
                    _InfoRow(
                      'Text Scale',
                      mediaQuery.textScaler.scale(1).toStringAsFixed(2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // View Info
              _InfoCard(
                title: 'View.of(context)',
                icon: Icons.visibility,
                color: Colors.purple,
                child: Column(
                  children: [
                    _InfoRow(
                      'Physical Size',
                      '${view.physicalSize.width.toStringAsFixed(0)} × ${view.physicalSize.height.toStringAsFixed(0)}',
                    ),
                    _InfoRow(
                      'Logical Size',
                      '${(view.physicalSize.width / view.devicePixelRatio).toStringAsFixed(1)} × ${(view.physicalSize.height / view.devicePixelRatio).toStringAsFixed(1)}',
                    ),
                    _InfoRow('Device Pixel Ratio', '${view.devicePixelRatio}x'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Binding Info
              _InfoCard(
                title: 'Virtual Binding',
                icon: Icons.settings_applications,
                color: Colors.teal,
                child: Column(
                  children: [
                    _InfoRow(
                      'Virtual Device Active',
                      binding.device != null ? 'Yes' : 'No',
                    ),
                    _InfoRow('Binding Device', binding.device?.name ?? 'None'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Demo Grid
              _InfoCard(
                title: 'Responsive Demo',
                icon: Icons.grid_view,
                color: Colors.pink,
                child: _ResponsiveGrid(),
              ),

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        );
      },
    );
  }

  String _formatEdgeInsets(EdgeInsets insets) {
    if (insets == EdgeInsets.zero) return 'none';
    return 'T:${insets.top.toInt()} B:${insets.bottom.toInt()} L:${insets.left.toInt()} R:${insets.right.toInt()}';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 500 ? 4 : (width > 300 ? 3 : 2);

        return Column(
          children: [
            Text(
              'Grid adapts to $crossAxisCount columns',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.primaries[index % Colors.primaries.length],
                        Colors.primaries[(index + 5) % Colors.primaries.length],
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'App is running...',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _QuickSwitchFAB extends StatelessWidget {
  const _QuickSwitchFAB({
    required this.devices,
    required this.currentDevice,
    required this.onDeviceSelected,
  });

  final List<DeviceInfo?> devices;
  final DeviceInfo? currentDevice;
  final ValueChanged<DeviceInfo?> onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickPicker(context),
      icon: const Icon(Icons.swap_horiz),
      label: const Text('Switch'),
    );
  }

  void _showQuickPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Quick Device Switch',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: devices.length.clamp(0, 10),
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final isSelected = device?.name == currentDevice?.name;

                    return ListTile(
                      leading: Icon(
                        device == null ? Icons.phone_android : Icons.devices,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(device?.name ?? 'Real Device'),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        onDeviceSelected(device);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
