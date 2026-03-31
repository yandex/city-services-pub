import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'view_configuration.dart';
import 'transforms.dart';
import '../device/info.dart';

/// The root of the render tree.
///
/// The view represents the total output surface of the render tree and handles
/// bootstrapping the rendering pipeline. The view has a unique child
/// [RenderBox], which is required to fill the entire output surface.
class VirtualRenderView extends RenderView {
  VirtualRenderView({
    RenderBox? child,
    ViewConfiguration? configuration,
    required ui.FlutterView view,
  }) : super(
          child: child,
          // Currently on mobile devices it is initialized with null.
          // Then, in [addRenderView], current [RenderView] get view configuration.
          // In code below define setter to wrap configuration in a virtual container.
          configuration: configuration,
          view: view,
        );

  DeviceInfo? _device;

  /// Get device info.
  DeviceInfo? get device => _device;

  /// Set device info.
  set device(DeviceInfo? value) {
    if (_device?.identifier != value?.identifier) {
      _device = value;
      applyVirtualConfiguration();
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  /// Universal function of applying a virtual configuration.
  void applyVirtualConfiguration() {
    final device = this.device;
    if (device != null) {
      final logicalSize = device.screenSizeOn(orientation);
      final pixelRatio = device.pixelRatio;
      final physical = BoxConstraints.tight(logicalSize) * pixelRatio;
      final logical = BoxConstraints.tight(logicalSize);

      // Set virtual device configuration
      configuration
        ..logicalConstraints = logical
        ..physicalConstraints = physical
        ..devicePixelRatio = pixelRatio;
    } else {
      // Restore last real configuration
      configuration.resetAll();
    }
  }

  /// Cast configuration to virtual. Everything here should be virtualized.
  @override
  VirtualViewConfiguration get configuration =>
      super.configuration as VirtualViewConfiguration;

  /// More complex configuration update logic is needed, as the configuration
  /// has a significant impact on the internal workings of the framework.
  @override
  set configuration(ViewConfiguration value) {
    if (hasConfiguration && device != null) {
      configuration.parent = value;
      applyVirtualConfiguration();
      markNeedsLayout();
    } else {
      super.configuration = VirtualViewConfiguration(parent: value);
    }
  }

  Color _backgroundColor = Colors.black54;

  /// Get background color.
  /// Default if black.
  Color get backgroundColor => _backgroundColor;

  /// Set background color.
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  Orientation _orientation = Orientation.portrait;

  /// Get device orientation.
  Orientation get orientation => _orientation;

  /// Set device orientation.
  set orientation(Orientation value) {
    if (_orientation != value) {
      _orientation = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final device = this.device;
    if (device != null) {
      context.canvas.drawColor(
        _backgroundColor,
        BlendMode.color,
      );

      context.pushTransform(
        needsCompositing,
        offset,
        VirtualTransforms.globalTransform(device, orientation),
        (context, offset) {
          final screenBounds = device.screenPath.getBounds();
          var screenPath = device.screenPath.shift(-screenBounds.topLeft);
          if (orientation == Orientation.landscape) {
            final screenTransform = Matrix4.rotationZ(pi * 0.5)
              ..translate(0.0, -screenBounds.height);
            screenPath = screenPath.transform(screenTransform.storage);
          }

          context.pushClipPath(
            needsCompositing,
            screenBounds.topLeft,
            screenBounds.shift(-screenBounds.topLeft),
            screenPath,
            (context, offset) {
              context.pushTransform(
                needsCompositing,
                offset,
                VirtualTransforms.screenScaleTransform(device),
                super.paint,
              );
            },
          );
        },
      );
    } else {
      super.paint(context, offset);
    }
  }
}
