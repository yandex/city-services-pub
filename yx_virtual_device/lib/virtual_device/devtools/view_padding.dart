import 'dart:ui';

import 'package:flutter/widgets.dart';

/// A representation of distances for each of the four edges of a rectangle,
/// used to encode the view insets and padding that applications should place
/// around their user interface, as exposed by [FlutterView.viewInsets] and
/// [FlutterView.padding]. View insets and padding are preferably read via
/// [MediaQuery.of].
class VirtualViewPadding implements ViewPadding {
  const VirtualViewPadding({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory VirtualViewPadding.fromEdgeInsets(
    EdgeInsets insets,
  ) =>
      VirtualViewPadding(
        left: insets.left,
        top: insets.top,
        right: insets.right,
        bottom: insets.bottom,
      );

  const VirtualViewPadding.all(double value)
      : left = value,
        right = value,
        top = value,
        bottom = value;

  @override
  final double left;

  @override
  final double top;

  @override
  final double right;

  @override
  final double bottom;

  EdgeInsets asEdgeInsets() => EdgeInsets.only(
        left: left,
        right: right,
        top: top,
        bottom: bottom,
      );

  @override
  String toString() {
    return 'VirtualViewPadding(left: $left, top: $top, right: $right, bottom: $bottom)';
  }
}
