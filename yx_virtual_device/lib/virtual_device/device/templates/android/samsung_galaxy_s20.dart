import 'package:flutter/widgets.dart';

import '../../identifier.dart';
import '../../info.dart';

final info = DeviceInfo(
  identifier: const DeviceIdentifier(
    TargetPlatform.android,
    DeviceType.phone,
    'samsung-galaxy-s20',
  ),
  name: 'Samsung Galaxy S20',
  pixelRatio: 4.0,
  safeAreas: const EdgeInsets.only(
    left: 0.0,
    top: 32.0,
    right: 0.0,
    bottom: 32.0,
  ),
  rotatedSafeAreas: const EdgeInsets.only(
    left: 32.0,
    top: 24.0,
    right: 32.0,
    bottom: 0.0,
  ),
  screenSize: const Size(360.0, 800.0),
  frameSize: const Size(856.54, 1899.0),
  screenPath:
      Path()
        ..moveTo(19.9199, 110.664)
        ..cubicTo(19.9199, 67.8815, 54.6022, 33.1992, 97.385, 33.1992)
        ..lineTo(761.371, 33.1992)
        ..cubicTo(804.154, 33.1992, 838.836, 67.8815, 838.836, 110.664)
        ..lineTo(838.836, 1775.06)
        ..cubicTo(838.836, 1817.84, 804.154, 1852.52, 761.371, 1852.52)
        ..lineTo(97.385, 1852.52)
        ..cubicTo(54.6022, 1852.52, 19.9199, 1817.84, 19.9199, 1775.06)
        ..lineTo(19.9199, 110.664)
        ..close()
        ..moveTo(425.133, 91.2657)
        ..cubicTo(437.357, 91.2657, 447.266, 81.3565, 447.266, 69.1329)
        ..cubicTo(447.266, 56.9092, 437.357, 47, 425.133, 47)
        ..cubicTo(412.909, 47, 403, 56.9092, 403, 69.1329)
        ..cubicTo(403, 81.3565, 412.909, 91.2657, 425.133, 91.2657)
        ..close()
        ..fillType = PathFillType.evenOdd,
);
