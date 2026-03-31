import 'package:flutter/widgets.dart';

import '../../identifier.dart';
import '../../info.dart';

final info = DeviceInfo(
  identifier: const DeviceIdentifier(
    TargetPlatform.iOS,
    DeviceType.tablet,
    'ipad-air-4',
  ),
  name: 'iPad Air 4',
  pixelRatio: 3.0,
  screenSize: const Size(820.0, 1180.0),
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
  frameSize: const Size(1811.0, 2509.0),
  screenPath:
      Path()
        ..moveTo(141.875, 111.275)
        ..cubicTo(121.902, 111.275, 105.711, 127.466, 105.711, 147.439)
        ..lineTo(105.711, 2367.37)
        ..cubicTo(105.711, 2387.35, 121.902, 2403.54, 141.875, 2403.54)
        ..lineTo(1663.56, 2403.54)
        ..cubicTo(1683.53, 2403.54, 1699.72, 2387.35, 1699.72, 2367.37)
        ..lineTo(1699.72, 147.439)
        ..cubicTo(1699.72, 127.466, 1683.53, 111.275, 1663.56, 111.275)
        ..lineTo(141.875, 111.275)
        ..close()
        ..fillType = PathFillType.evenOdd,
);
