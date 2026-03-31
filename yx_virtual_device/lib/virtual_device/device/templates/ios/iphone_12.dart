import 'package:flutter/widgets.dart';

import '../../identifier.dart';
import '../../info.dart';

final info = DeviceInfo(
  identifier: const DeviceIdentifier(
    TargetPlatform.iOS,
    DeviceType.phone,
    'iphone-12',
  ),
  name: 'iPhone 12',
  pixelRatio: 2.0,
  safeAreas: const EdgeInsets.only(
    left: 0.0,
    top: 44.0,
    right: 0.0,
    bottom: 34.0,
  ),
  rotatedSafeAreas: const EdgeInsets.only(
    left: 44.0,
    top: 24.0,
    right: 44.0,
    bottom: 21.0,
  ),
  frameSize: const Size(873.0, 1771.0),
  screenSize: const Size(390.0, 844.0),
  screenPath:
      Path()
        ..moveTo(224.958, 50.564)
        ..lineTo(224.958, 59.8513)
        ..lineTo(225.106, 59.8466)
        ..lineTo(224.958, 60.8831)
        ..cubicTo(224.958, 85.3893, 244.824, 105.255, 269.33, 105.255)
        ..lineTo(603.67, 105.255)
        ..cubicTo(628.176, 105.255, 648.043, 85.3893, 648.043, 60.8831)
        ..lineTo(647.895, 59.8466)
        ..lineTo(648.042, 59.8513)
        ..lineTo(648.042, 50.564)
        ..cubicTo(648.042, 44.295, 653.124, 39.213, 659.393, 39.213)
        ..lineTo(685.976, 39.2129)
        ..cubicTo(727.533, 39.2129, 748.311, 39.2129, 764.883, 45.4748)
        ..cubicTo(790.93, 55.3172, 811.492, 75.8786, 821.334, 101.926)
        ..cubicTo(827.596, 118.498, 827.596, 139.276, 827.596, 180.833)
        ..lineTo(827.596, 1589.93)
        ..cubicTo(827.596, 1631.49, 827.596, 1652.27, 821.334, 1668.84)
        ..cubicTo(811.492, 1694.89, 790.93, 1715.45, 764.883, 1725.29)
        ..cubicTo(748.311, 1731.55, 727.533, 1731.55, 685.976, 1731.55)
        ..lineTo(187.024, 1731.55)
        ..cubicTo(145.467, 1731.55, 124.689, 1731.55, 108.117, 1725.29)
        ..cubicTo(82.07, 1715.45, 61.5086, 1694.89, 51.6662, 1668.84)
        ..cubicTo(45.4043, 1652.27, 45.4043, 1631.49, 45.4043, 1589.93)
        ..lineTo(45.4043, 180.833)
        ..cubicTo(45.4043, 139.276, 45.4043, 118.498, 51.6662, 101.926)
        ..cubicTo(61.5086, 75.8786, 82.07, 55.3172, 108.117, 45.4748)
        ..cubicTo(124.689, 39.2129, 145.467, 39.2129, 187.024, 39.2129)
        ..lineTo(213.607, 39.213)
        ..cubicTo(219.876, 39.213, 224.958, 44.295, 224.958, 50.564)
        ..close()
        ..fillType = PathFillType.evenOdd,
);
