import '../../info.dart';

import 'iphone_12_mini.dart' as iphone_12_mini;
import 'iphone_12.dart' as iphone_12;
import 'iphone_12_pro_max.dart' as iphone_12_pro_max;
import 'iphone_13_mini.dart' as iphone_13_mini;
import 'iphone_13.dart' as iphone_13;
import 'iphone_13_pro_max.dart' as iphone_13_pro_max;
import 'iphone_14_pro.dart' as iphone_14_pro;
import 'iphone_se.dart' as iphone_se;
import 'ipad_air_4.dart' as ipad_air_4;
import 'ipad_pro_11inches.dart' as ipad_pro_11inches;
import 'ipad_pro_12inches_gen2.dart' as ipad_pro_12inches_gen2;
import 'ipad_pro_12inches_gen4.dart' as ipad_pro_12inches_gen4;

/// A set of iOS devices.
class IosDevices {
  const IosDevices();

  DeviceInfo get iPhone12Mini => iphone_12_mini.info;
  DeviceInfo get iPhone12 => iphone_12.info;
  DeviceInfo get iPhone12ProMax => iphone_12_pro_max.info;
  DeviceInfo get iPhone13Mini => iphone_13_mini.info;
  DeviceInfo get iPhone13 => iphone_13.info;
  DeviceInfo get iPhone13ProMax => iphone_13_pro_max.info;
  DeviceInfo get iPhone14Pro => iphone_14_pro.info;
  DeviceInfo get iPhoneSE => iphone_se.info;
  DeviceInfo get iPadAir4 => ipad_air_4.info;
  DeviceInfo get iPadPro11Inches => ipad_pro_11inches.info;
  DeviceInfo get iPad12InchesGen2 => ipad_pro_12inches_gen2.info;
  DeviceInfo get iPad12InchesGen4 => ipad_pro_12inches_gen4.info;

  /// All devices.
  List<DeviceInfo> get all => [
        // Phones
        iPhone12Mini,
        iPhone12,
        iPhone12ProMax,
        iPhone13Mini,
        iPhone13,
        iPhone13ProMax,
        iPhone14Pro,
        iPhoneSE,
        //Tablets
        iPadAir4,
        iPadPro11Inches,
      ];
}
