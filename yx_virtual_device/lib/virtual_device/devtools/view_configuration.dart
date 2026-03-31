// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// The layout constraints for the root render object.
class VirtualViewConfiguration extends ViewConfiguration {
  ViewConfiguration? _parent;

  /// Real [ViewConfiguration].
  ViewConfiguration get parent => _parent!;

  set parent(ViewConfiguration value) {
    if (value is VirtualViewConfiguration) {
      throw Exception('Parent view configuration must be non virtual!');
    }
    _parent = value;
  }

  VirtualViewConfiguration({ViewConfiguration? parent})
    : assert(
        parent is! VirtualViewConfiguration,
        'Parent view configuration must be non virtual!',
      ),
      _parent = parent;

  BoxConstraints? _logicalConstraints;

  @override
  BoxConstraints get logicalConstraints =>
      _logicalConstraints ?? parent.logicalConstraints;

  set logicalConstraints(BoxConstraints value) {
    _logicalConstraints = value;
  }

  /// Reset configuration to real device logical constraints.
  void resetLogicalConstraints() {
    _logicalConstraints = null;
  }

  BoxConstraints? _physicalConstraints;

  @override
  BoxConstraints get physicalConstraints =>
      _physicalConstraints ?? parent.physicalConstraints;

  set physicalConstraints(BoxConstraints value) {
    _physicalConstraints = value;
  }

  /// Reset configuration to real device physical constraints.
  void resetPhysicalConstraints() {
    _physicalConstraints = null;
  }

  double? _devicePixelRatio;

  @override
  double get devicePixelRatio => _devicePixelRatio ?? parent.devicePixelRatio;

  set devicePixelRatio(double value) {
    _devicePixelRatio = value;
  }

  /// Reset configuration to real device pixel ratios.
  void resetDevicePixelRatios() {
    _devicePixelRatio = null;
  }

  /// Reset all configuration to real device.
  void resetAll() {
    resetLogicalConstraints();
    resetPhysicalConstraints();
    resetDevicePixelRatios();
  }

  @override
  Matrix4 toMatrix() {
    final pixelRatio = parent.devicePixelRatio;
    return Matrix4.diagonal3Values(pixelRatio, pixelRatio, 1.0);
  }

  @override
  bool shouldUpdateMatrix(ViewConfiguration oldConfiguration) {
    final old = oldConfiguration as VirtualViewConfiguration;
    return old.parent.devicePixelRatio != parent.devicePixelRatio;
  }

  @override
  Size toPhysicalSize(Size logicalSize) {
    return parent.physicalConstraints.constrain(
      logicalSize * parent.devicePixelRatio,
    );
  }

  @override
  bool operator ==(Object other) =>
      (other is ViewConfiguration || other is VirtualViewConfiguration) &&
      hashCode == other.hashCode;

  @override
  String toString() =>
      'parent: ${parent.toString()}\n'
      'result: $logicalConstraints at ${debugFormatDouble(devicePixelRatio)}x';
}
