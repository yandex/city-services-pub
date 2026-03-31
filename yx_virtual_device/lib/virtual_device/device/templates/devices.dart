import '../info.dart';
import 'android/android.dart';
import 'ios/ios.dart';
import 'standard.dart';

/// A list of common device specifications sorted by target platform.
abstract class Devices {
  /// All iOS devices.
  static const ios = IosDevices();

  /// All Android devices.
  static const android = AndroidDevices();

  /// All Custom devices.
  static List<DeviceInfo> get custom => [...ios.all, ...android.all];

  /// All Standard devices.
  static const standard = StandardDevices();

  /// All available devices.
  static List<DeviceInfo> get all => [
    ...standard.all,
    ...ios.all,
    ...android.all,
  ];
}
