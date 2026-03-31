import 'package:flutter/widgets.dart';

import '../../identifier.dart';
import '../../info.dart';

final info = DeviceInfo(
  identifier: const DeviceIdentifier(
    TargetPlatform.iOS,
    DeviceType.tablet,
    'ipad-pro-11inches',
  ),
  name: 'iPad Pro (11")',
  pixelRatio: 3.0,
  screenSize: const Size(834.0, 1194.0),
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
  frameSize: const Size(1741.0, 2412.0),
  screenPath:
      Path()
        ..moveTo(90.9277, 128.369)
        ..lineTo(90.9277, 2289.24)
        ..cubicTo(90.9277, 2306.97, 105.296, 2321.33, 123.02, 2321.33)
        ..lineTo(1612.63, 2321.33)
        ..cubicTo(1630.36, 2321.33, 1644.72, 2306.97, 1644.72, 2289.24)
        ..lineTo(1644.72, 128.369)
        ..cubicTo(1644.72, 110.645, 1630.36, 96.2765, 1612.63, 96.2765)
        ..lineTo(123.02, 96.2765)
        ..cubicTo(105.296, 96.2765, 90.9277, 110.645, 90.9277, 128.369)
        ..close()
        ..fillType = PathFillType.evenOdd,
);
