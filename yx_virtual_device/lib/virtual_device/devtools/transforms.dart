import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../device/info.dart';

/// Helps to correctly project a virtual screen on a real one.
abstract class VirtualTransforms {
  static Rect globalDestinationRect(
    DeviceInfo device,
    Orientation orientation,
  ) {
    final view = ui.PlatformDispatcher.instance.implicitView!;

    final outputPadding =
        EdgeInsets.only(
              left: view.padding.left,
              right: view.padding.right,
              top: view.padding.top,
              bottom: view.padding.bottom,
            ) /
            view.devicePixelRatio +
        const EdgeInsets.all(10);

    final output = Size(
      (view.physicalSize.width / view.devicePixelRatio) -
          outputPadding.horizontal,
      (view.physicalSize.height / view.devicePixelRatio) -
          outputPadding.vertical,
    );

    final frameSize = device.frameSizeOn(orientation);
    final sizes = applyBoxFit(BoxFit.contain, frameSize, output);

    return Alignment.center.inscribe(
      sizes.destination,
      Offset(outputPadding.left, outputPadding.top) & output,
    );
  }

  static Matrix4 globalTransform(DeviceInfo device, Orientation orientation) {
    final destinationRect = globalDestinationRect(device, orientation);
    final frameSize = device.frameSizeOn(orientation);

    final scaleX = destinationRect.width / frameSize.width;
    final scaleY = destinationRect.height / frameSize.height;

    return Matrix4.translationValues(
        destinationRect.left,
        destinationRect.top,
        0.0,
      )
      // ignore: deprecated_member_use
      ..scale(scaleX, scaleY, 1.0);
  }

  static Matrix4 screenTranslateTransform(
    DeviceInfo device, [
    bool inverted = false,
  ]) {
    final translate = screenTranslate(device);
    return Matrix4.translationValues(translate.dx, translate.dy, 0);
  }

  static Rect screenDestinationRect(
    DeviceInfo device,
    Orientation orientation,
  ) {
    final destinationRect = globalDestinationRect(device, orientation);
    final frameSize = device.frameSizeOn(orientation);
    final scaleX = destinationRect.width / frameSize.width;
    final scaleY = destinationRect.height / frameSize.height;

    var screenBounds = device.screenPath.getBounds();
    if (orientation == Orientation.landscape) {
      screenBounds =
          Offset(
            device.frameSize.height - screenBounds.bottom,
            screenBounds.left,
          ) &
          screenBounds.size.flipped;
    }
    return (destinationRect.topLeft +
            Offset(screenBounds.left * scaleX, screenBounds.top * scaleY)) &
        Size(screenBounds.width * scaleX, screenBounds.height * scaleY);
  }

  static Offset screenTranslate(DeviceInfo device, [bool inverted = false]) {
    final screenOffset = device.screenPath.getBounds().topLeft;
    return Offset(
      screenOffset.dx * (inverted ? -1 : 1),
      screenOffset.dy * (inverted ? -1 : 1),
    );
  }

  static Matrix4 screenScaleTransform(DeviceInfo device) {
    final scale = device.screenPath.getBounds().width / device.screenSize.width;

    // ignore: deprecated_member_use
    return Matrix4.identity()..scale(scale);
  }
}
