import 'package:flutter/widgets.dart';

import '../../identifier.dart';
import '../../info.dart';

final info = DeviceInfo(
  identifier: const DeviceIdentifier(
    TargetPlatform.iOS,
    DeviceType.phone,
    'iphone-se',
  ),
  name: 'iPhone SE',
  pixelRatio: 2.0,
  screenSize: const Size(375.0, 667.0),
  safeAreas: const EdgeInsets.only(
    left: 0.0,
    top: 20.0,
    right: 0.0,
    bottom: 0.0,
  ),
  rotatedSafeAreas: const EdgeInsets.only(
    left: 0.0,
    top: 20.0,
    right: 0.0,
    bottom: 0.0,
  ),
  frameSize: const Size(891.0, 1790.0),
  screenPath:
      Path()
        ..moveTo(836.747, 198.193)
        ..lineTo(54.2529, 198.193)
        ..lineTo(54.2529, 1589.72)
        ..lineTo(836.747, 1589.72)
        ..lineTo(836.747, 198.193)
        ..close()
        ..fillType = PathFillType.evenOdd,
);
