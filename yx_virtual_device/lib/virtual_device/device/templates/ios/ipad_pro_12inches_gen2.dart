import 'package:flutter/widgets.dart';

import '../../identifier.dart';
import '../../info.dart';

final info = DeviceInfo(
  identifier: const DeviceIdentifier(
    TargetPlatform.iOS,
    DeviceType.tablet,
    'ipad-pro-12inches-gen2',
  ),
  name: 'iPad Pro (12" gen 2)',
  pixelRatio: 2.0,
  screenSize: const Size(1024.0, 1366.0),
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
  frameSize: const Size(1744.0, 2409.0),
  screenPath:
      Path()
        ..moveTo(1656.41, 161.872)
        ..lineTo(93.5703, 161.872)
        ..lineTo(93.5703, 2246.68)
        ..lineTo(1656.41, 2246.68)
        ..lineTo(1656.41, 161.872)
        ..close()
        ..fillType = PathFillType.evenOdd,
);
