import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'identifier.dart';

/// Info about a device and its frame.
class DeviceInfo {
  /// Identifier of the device.
  final DeviceIdentifier identifier;

  /// The display name of the device.
  final String name;

  /// The safe areas when the device is in landscape orientation.
  final EdgeInsets? rotatedSafeAreas;

  /// The safe areas when the device is in portrait orientation.
  final EdgeInsets safeAreas;

  /// The screen pixel density of the device.
  final double pixelRatio;

  /// The size in points of the screen content.
  final Size screenSize;

  /// A shape representing the screen.
  final Path screenPath;

  /// The frame size in pixels.
  final Size frameSize;

  /// The safe area choice depends on the orientation.
  EdgeInsets safeAreasOn(Orientation orientation) =>
      orientation == Orientation.portrait
          ? safeAreas
          : rotatedSafeAreas ?? safeAreas;

  /// The frame size choice depends on the orientation.
  Size frameSizeOn(Orientation orientation) =>
      orientation == Orientation.portrait ? frameSize : frameSize.flipped;

  /// The screen size choice depends on the orientation.
  Size screenSizeOn(Orientation orientation) =>
      orientation == Orientation.portrait ? screenSize : screenSize.flipped;

  /// The screen path bounds choice depends on the orientation.
  Size screenPathBoundsOn(Orientation orientation) =>
      orientation == Orientation.portrait
          ? screenPath.getBounds().size
          : screenPath.getBounds().size.flipped;

  /// Device screen configuration.
  const DeviceInfo({
    required this.identifier,
    required this.name,
    this.rotatedSafeAreas,
    required this.frameSize,
    required this.safeAreas,
    required this.pixelRatio,
    required this.screenSize,
    required this.screenPath,
  });

  /// Create phone screen configuration.
  factory DeviceInfo.genericPhone({
    required TargetPlatform platform,
    required String id,
    required String name,
    required Size screenSize,
    EdgeInsets safeAreas = EdgeInsets.zero,
    EdgeInsets rotatedSafeAreas = EdgeInsets.zero,
    double pixelRatio = 2.0,
  }) => DeviceInfo(
    identifier: DeviceIdentifier(platform, DeviceType.phone, id),
    name: name,
    screenSize: screenSize,
    safeAreas: safeAreas,
    rotatedSafeAreas: rotatedSafeAreas,
    pixelRatio: pixelRatio,
    frameSize: calculatePhoneFrameSize(screenSize),
    screenPath: createPhoneScreenPath(screenSize),
  );

  /// Helper to calculate generic phone frame size.
  static Size calculatePhoneFrameSize(Size screenSize) {
    return Size(screenSize.width, screenSize.height);
  }

  /// Helper to create generic phone screen path.
  static Path createPhoneScreenPath(Size screenSize) {
    final rect = Offset.zero & screenSize;
    final result = Path();
    result.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)));
    return result;
  }

  /// Create tablet screen configuration.
  factory DeviceInfo.genericTablet({
    required TargetPlatform platform,
    required String id,
    required String name,
    required Size screenSize,
    EdgeInsets safeAreas = EdgeInsets.zero,
    EdgeInsets rotatedSafeAreas = EdgeInsets.zero,
    double pixelRatio = 2.0,
  }) => DeviceInfo(
    identifier: DeviceIdentifier(platform, DeviceType.tablet, id),
    name: name,
    screenSize: screenSize,
    safeAreas: safeAreas,
    rotatedSafeAreas: rotatedSafeAreas,
    pixelRatio: pixelRatio,
    frameSize: calculateTabletFrameSize(screenSize),
    screenPath: createTabletScreenPath(screenSize),
  );

  /// Helper to calculate generic tablet frame size.
  static Size calculateTabletFrameSize(Size screenSize) {
    return Size(screenSize.width, screenSize.height);
  }

  /// Helper to create generic tablet screen path.
  static Path createTabletScreenPath(Size screenSize) {
    final rect = Offset.zero & screenSize;
    final result = Path();
    result.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)));
    return result;
  }

  /// Indicates whether the device can rotate.
  bool get canRotate => rotatedSafeAreas != null;

  /// Indicates whether the current device info should be in landscape.
  ///
  /// This is true only if the device can rotate.
  bool isLandscape(Orientation orientation) {
    return canRotate && orientation == Orientation.landscape;
  }
}
