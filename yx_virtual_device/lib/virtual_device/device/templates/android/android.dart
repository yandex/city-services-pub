import '../../info.dart';

import 'samsung_galaxy_s20.dart' as samsung_galaxy_s20;
import 'samsung_galaxy_note20_ultra.dart' as samsung_galaxy_note20_ultra;
import 'samsung_galaxy_a50.dart' as samsung_galaxy_a50;
import 'oneplus_8_pro.dart' as oneplus_8_pro;

/// A set of iOS devices.
class AndroidDevices {
  const AndroidDevices();

  DeviceInfo get samsungGalaxyS20 => samsung_galaxy_s20.info;

  DeviceInfo get samsungGalaxyNote20Ultra => samsung_galaxy_note20_ultra.info;

  DeviceInfo get samsungGalaxyA50 => samsung_galaxy_a50.info;

  DeviceInfo get onePlus8Pro => oneplus_8_pro.info;

  /// All available devices.
  List<DeviceInfo> get all => [
    //Phones
    samsungGalaxyA50,
    samsungGalaxyS20,
    samsungGalaxyNote20Ultra,
    onePlus8Pro,
  ];
}
