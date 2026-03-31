import 'package:flutter/widgets.dart';

import '../../identifier.dart';
import '../../info.dart';

final info = DeviceInfo(
  identifier: const DeviceIdentifier(
    TargetPlatform.iOS,
    DeviceType.phone,
    'iphone-14-pro',
  ),
  name: 'iPhone 14 Pro',
  pixelRatio: 3.0,
  screenSize: const Size(393.0, 852.0),
  // ToDo: Real paddings
  safeAreas: const EdgeInsets.only(
    left: 0.0,
    top: 52.0,
    right: 0.0,
    bottom: 34.0,
  ),
  rotatedSafeAreas: const EdgeInsets.only(
    left: 52.0,
    top: 0.0,
    right: 52.0,
    bottom: 21.0,
  ),
  frameSize: const Size(393, 852),
  screenPath: Path()
    ..moveTo(57, 0)
    ..cubicTo(25.5198, 0, 0, 25.5198, 0, 57)
    ..lineTo(0, 795)
    ..cubicTo(0, 826.48, 25.5198, 852, 57, 852)
    ..lineTo(336, 852)
    ..cubicTo(367.48, 852, 393, 826.48, 393, 795)
    ..lineTo(393, 57)
    ..cubicTo(393, 25.5198, 367.48, 0, 336, 0)
    ..lineTo(196.5, 0)
    ..lineTo(57, 0)
    ..close()
    ..moveTo(154, 11)
    ..cubicTo(143.507, 11, 135, 19.5066, 135, 30)
    ..cubicTo(135, 40.4934, 143.507, 49, 154, 49)
    ..lineTo(241, 49)
    ..cubicTo(251.493, 49, 260, 40.4934, 260, 30)
    ..cubicTo(260, 19.5066, 251.493, 11, 241, 11)
    ..lineTo(154, 11)
    ..close()
    ..fillType = PathFillType.evenOdd,
);
