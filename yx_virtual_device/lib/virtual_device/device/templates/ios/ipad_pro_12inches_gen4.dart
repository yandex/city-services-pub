import 'package:flutter/widgets.dart';

import '../../identifier.dart';
import '../../info.dart';

final info = DeviceInfo(
  identifier: const DeviceIdentifier(
    TargetPlatform.iOS,
    DeviceType.tablet,
    'ipad-pro-12inches-gen4',
  ),
  name: 'iPad Pro (12" gen 4)',
  pixelRatio: 2.0,
  screenSize: const Size(1024, 1366.0),
  safeAreas: const EdgeInsets.only(
    left: 0.0,
    top: 24.0,
    right: 0.0,
    bottom: 20.0,
  ),
  rotatedSafeAreas: const EdgeInsets.only(
    left: 0.0,
    top: 24.0,
    right: 0.0,
    bottom: 20.0,
  ),
  frameSize: const Size(1849.0, 2424.0),
  screenPath:
      Path()
        ..moveTo(77.7461, 126.292)
        ..lineTo(77.7461, 2314.52)
        ..cubicTo(77.7461, 2332.47, 93.3654, 2347.02, 112.633, 2347.02)
        ..lineTo(1731.96, 2347.02)
        ..cubicTo(1751.22, 2347.02, 1766.84, 2332.47, 1766.84, 2314.52)
        ..lineTo(1766.84, 126.292)
        ..cubicTo(1766.84, 108.344, 1751.22, 93.7939, 1731.96, 93.7939)
        ..lineTo(112.633, 93.7939)
        ..cubicTo(93.3654, 93.7939, 77.7461, 108.344, 77.7461, 126.292)
        ..close()
        ..fillType = PathFillType.evenOdd,
);
