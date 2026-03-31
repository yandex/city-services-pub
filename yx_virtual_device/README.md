# yx_virtual_device

<div align="center">

<img src="https://github.com/yandex/city-services-pub/blob/main/yx_virtual_device/screenshots/Logo.webp?raw=true" width="200" alt="The yx_virtual_device package logo" />

**A utility for testing the user interface for Flutter applications.**

[![Pub Version](https://img.shields.io/pub/v/yx_virtual_device)](https://pub.dev/packages/yx_virtual_device)
</div>

---

A Flutter package for simulating different device screens during development. Test your responsive layouts on various device sizes without needing physical devices or multiple emulators.

It is important not to use it for release builds!!!

![Example](https://github.com/yandex/city-services-pub/blob/main/yx_virtual_device/screenshots/Example.gif)

## Features

- 📱 Simulate iOS, Android, and custom device screens
- 🔄 Hot-swap devices at runtime
- 📐 Accurate screen sizes, pixel ratios, and safe areas
- 🎨 Works with existing Flutter widgets (MediaQuery, LayoutBuilder, etc.)

## Screenshots

![Phone](https://github.com/yandex/city-services-pub/blob/main/yx_virtual_device/screenshots/Phone.webp) ![Tablet](https://github.com/yandex/city-services-pub/blob/main/yx_virtual_device/screenshots/Tablet.webp)

## Installation

```yaml
dependencies:
  yx_virtual_device: ^1.0.0
```

## Quick Start

### 1. Setup Bindings

Initialize the virtual device bindings before `runApp`:

```dart
import 'package:flutter/material.dart';
import 'package:yx_virtual_device/yx_virtual_device.dart';

void main() {
  VirtualDeviceDevtools.setup();
  runApp(const MyApp());
}
```

### 2. Switch Devices

Use `VirtualDeviceDevtools.setDevice()` to change the simulated device:

```dart
// Set a specific device
VirtualDeviceDevtools.setDevice(Devices.ios.iPhone13);

// Reset to real device
VirtualDeviceDevtools.setDevice(null);
```

## Available Devices

### Standard Devices

![Standard group](https://github.com/yandex/city-services-pub/blob/main/yx_virtual_device/screenshots/Standard.webp)

```dart
Devices.standard.w360p3   // 360×800 @3x
Devices.standard.w375p3   // 375×812 @3x
Devices.standard.w414p3   // 414×896 @3x
// ... and more
```

### iOS Devices

```dart
Devices.ios.iPhone13
Devices.ios.iPhone13ProMax
Devices.ios.iPhoneSE
Devices.ios.iPadPro
// ... and more
```

### Android Devices

```dart
Devices.android.samsungGalaxyS21
Devices.android.pixel5
Devices.android.onePlus9
// ... and more
```

### Get All Devices

```dart
// All devices
final allDevices = Devices.all;

// By platform
final iosDevices = Devices.ios.all;
final androidDevices = Devices.android.all;
final standardDevices = Devices.standard.all;
```

## Custom Devices

Create your own device configurations:

```dart
final myDevice = DeviceInfo(
  identifier: const DeviceIdentifier(
    TargetPlatform.android,
    DeviceType.phone,
    'my-custom-device',
  ),
  name: 'My Custom Device',
  pixelRatio: 3.0,
  screenSize: const Size(400, 800),
  safeAreas: const EdgeInsets.only(top: 44, bottom: 34),
  rotatedSafeAreas: const EdgeInsets.only(left: 44, right: 44),
);

VirtualDeviceDevtools.setDevice(myDevice);
```

## Example

```dart
import 'package:flutter/material.dart';
import 'package:yx_virtual_device/yx_virtual_device.dart';

void main() {
  // Called before [runApp] to replace bindings.
  // It is good not to use it in the production.
  if (kProfileMode || kDebugMode) {
      VirtualDeviceDevtools.setup();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DeviceInfo? _currentDevice;

  void _setDevice(DeviceInfo? device) {
    setState(() {
      _currentDevice = device;
      VirtualDeviceDevtools.setDevice(device);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(_currentDevice?.name ?? 'Real Device'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final mq = MediaQuery.of(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Screen: ${mq.size.width.toInt()}×${mq.size.height.toInt()}'),
                  Text('Pixel Ratio: ${mq.devicePixelRatio}x'),
                  Text('Constraints: ${constraints.maxWidth.toInt()}×${constraints.maxHeight.toInt()}'),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showDevicePicker(context),
          child: const Icon(Icons.devices),
        ),
      ),
    );
  }

  void _showDevicePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final devices = <DeviceInfo?>[
          null,
          ...Devices.standard.all,
          ...Devices.ios.all.take(5),
          ...Devices.android.all.take(5),
        ];

        return ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return ListTile(
              leading: Icon(device == null ? Icons.phone_android : Icons.devices),
              title: Text(device?.name ?? 'Real Device'),
              subtitle: device != null
                  ? Text('${device.screenSize.width.toInt()}×${device.screenSize.height.toInt()} @${device.pixelRatio}x')
                  : null,
              selected: device?.name == _currentDevice?.name,
              onTap: () {
                _setDevice(device);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
```

## Accessing Device Info

### From Binding

```dart
final binding = VirtualWidgetsFlutterBinding.virtualBinding;
final currentDevice = binding.device;
```

### From MediaQuery

```dart
final mq = MediaQuery.of(context);
print('Size: ${mq.size}');
print('Pixel Ratio: ${mq.devicePixelRatio}');
print('Padding: ${mq.padding}');
```

### From View

```dart
final view = View.of(context);
print('Physical Size: ${view.physicalSize}');
print('Device Pixel Ratio: ${view.devicePixelRatio}');
```

## API Reference

### VirtualDeviceDevtools

| Method | Description |
|--------|-------------|
| `setup()` | Initialize virtual device bindings |
| `setDevice(DeviceInfo?)` | Set the current virtual device |

### DeviceInfo

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Display name |
| `identifier` | `DeviceIdentifier` | Unique identifier |
| `screenSize` | `Size` | Logical screen size |
| `pixelRatio` | `double` | Device pixel ratio |
| `safeAreas` | `EdgeInsets` | Safe area insets (portrait) |
| `rotatedSafeAreas` | `EdgeInsets` | Safe area insets (landscape) |
| `frameSize` | `Size?` | Device frame size (optional) |
| `screenPath` | `Path?` | Screen clip path (optional) |

### DeviceIdentifier

| Property | Type | Description |
|----------|------|-------------|
| `platform` | `TargetPlatform` | Target platform |
| `type` | `DeviceType` | Device type (phone, tablet, etc.) |
| `id` | `String` | Unique string identifier |

### Devices

| Property | Type | Description |
|----------|------|-------------|
| `all` | `List<DeviceInfo>` | All available devices |
| `ios` | `IosDevices` | iOS devices |
| `android` | `AndroidDevices` | Android devices |
| `standard` | `StandardDevices` | Standard screen sizes |

## Use Cases

- 📱 **Responsive Testing** - Test layouts on different screen sizes
- 🎨 **Design Verification** - Verify designs match specifications
- 📸 **Screenshots** - Generate screenshots for various devices
- 🐛 **Bug Reproduction** - Reproduce device-specific layout issues

## License

MIT License
