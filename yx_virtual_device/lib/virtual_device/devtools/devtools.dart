import 'package:flutter/widgets.dart';

import '../device/info.dart';
import 'bindings.dart';

abstract class VirtualDeviceDevtools {
  /// Shows the availability of devtools.
  static bool available = false;

  /// Initializes the subsystems of the virtual device.
  /// You need to call it before [runApp].
  static void setup() {
    VirtualWidgetsFlutterBinding.ensureInitialized();
    available = true;
  }

  /// Set auto orientation mode
  static void setAutoOrientation(bool enabled) {
    if (available) {
      VirtualWidgetsFlutterBinding.virtualBinding.autoOrientation = enabled;
    }
  }

  /// Dunking the system orientation.
  static void setOrientation(Orientation orientation) {
    if (available) {
      VirtualWidgetsFlutterBinding.virtualBinding.orientation = orientation;
    }
  }

  /// Switches the system orientation.
  static void toggleOrientation() {
    if (available) {
      final binding = VirtualWidgetsFlutterBinding.virtualBinding;
      final orientation = binding.orientation;
      binding.orientation =
          (orientation == Orientation.portrait
              ? Orientation.landscape
              : Orientation.portrait);
    }
  }

  /// Simulate the Device of the transferred device.
  /// The application itself is reassembled when everything is ready.
  static void setDevice(DeviceInfo? device) {
    if (available) {
      VirtualWidgetsFlutterBinding.virtualBinding.device = device;
    }
  }
}
