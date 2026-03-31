import 'dart:ui';

import 'display.dart';
import 'platform_dispatcher.dart';

/// A view into which a Flutter [Scene] is drawn.
///
/// Each [FlutterView] has its own layer tree that is rendered
/// whenever [render] is called on it with a [Scene].
///
/// References to [FlutterView] objects are obtained via the [PlatformDispatcher].
class VirtualFlutterView implements FlutterView {
  VirtualFlutterView({
    required FlutterView view,
    required VirtualPlatformDispatcher platformDispatcher,
    required VirtualDisplay display,
  })  : parent = view,
        _platformDispatcher = platformDispatcher,
        _display = display;

  /// Real [FlutterView].
  final FlutterView parent;

  @override
  VirtualPlatformDispatcher get platformDispatcher => _platformDispatcher;
  final VirtualPlatformDispatcher _platformDispatcher;

  @override
  VirtualDisplay get display => _display;
  final VirtualDisplay _display;

  @override
  int get viewId => parent.viewId;

  @override
  double get devicePixelRatio =>
      _display.vDevicePixelRatio ?? parent.devicePixelRatio;

  set devicePixelRatio(double value) {
    _display.devicePixelRatio = value;
  }

  /// Reset configuration to real device pixel ratio.
  void resetDevicePixelRatio(bool notify) {
    _display.resetDevicePixelRatio(notify);
  }

  @override
  List<DisplayFeature> get displayFeatures =>
      _displayFeatures ?? parent.displayFeatures;
  List<DisplayFeature>? _displayFeatures;

  set displayFeatures(List<DisplayFeature> value) {
    _displayFeatures = value;
    platformDispatcher.onMetricsChanged?.call();
  }

  /// Reset configuration to real device display features.
  void resetDisplayFeatures(bool notify) {
    _displayFeatures = null;
    if (notify) {
      platformDispatcher.onMetricsChanged?.call();
    }
  }

  @override
  ViewPadding get padding => _padding ?? parent.padding;
  ViewPadding? _padding;

  set padding(ViewPadding value) {
    _padding = value;
    platformDispatcher.onMetricsChanged?.call();
  }

  /// Reset configuration to real device padding.
  void resetPadding(bool notify) {
    _padding = null;
    if (notify) {
      platformDispatcher.onMetricsChanged?.call();
    }
  }

  @override
  Size get physicalSize => _physicalSize ?? parent.physicalSize;
  Size? _physicalSize;

  set physicalSize(Size value) {
    _physicalSize = value;

    physicalConstraints = ViewConstraints.tight(value);
  }

  /// Reset configuration to real device physical size.
  void resetPhysicalSize(bool notify) {
    _physicalSize = null;
    resetPhysicalConstraints(notify);
  }

  @override
  ViewConstraints get physicalConstraints =>
      _physicalConstraints ?? parent.physicalConstraints;
  ViewConstraints? _physicalConstraints;

  set physicalConstraints(ViewConstraints value) {
    _physicalConstraints = value;
    platformDispatcher.onMetricsChanged?.call();
  }

  /// Reset configuration to real device physical constraints.
  void resetPhysicalConstraints(bool notify) {
    _physicalConstraints = null;
    if (notify) {
      platformDispatcher.onMetricsChanged?.call();
    }
  }

  @override
  ViewPadding get systemGestureInsets =>
      _systemGestureInsets ?? parent.systemGestureInsets;
  ViewPadding? _systemGestureInsets;

  set systemGestureInsets(ViewPadding value) {
    _systemGestureInsets = value;
    platformDispatcher.onMetricsChanged?.call();
  }

  /// Reset configuration to real device system gesture insets.
  void resetSystemGestureInsets(bool notify) {
    _systemGestureInsets = null;
    if (notify) {
      platformDispatcher.onMetricsChanged?.call();
    }
  }

  @override
  ViewPadding get viewInsets => parentInsets ?? parent.viewInsets;
  ViewPadding? parentInsets;

  set viewInsets(ViewPadding value) {
    parentInsets = value;
    platformDispatcher.onMetricsChanged?.call();
  }

  /// Reset configuration to real device view insets.
  void resetViewInsets(bool notify) {
    parentInsets = null;
    if (notify) {
      platformDispatcher.onMetricsChanged?.call();
    }
  }

  @override
  ViewPadding get viewPadding => parentPadding ?? parent.viewPadding;
  ViewPadding? parentPadding;

  set viewPadding(ViewPadding value) {
    parentPadding = value;
    platformDispatcher.onMetricsChanged?.call();
  }

  /// Reset configuration to real device view padding.
  void resetViewPadding(bool notify) {
    parentPadding = null;
    if (notify) {
      platformDispatcher.onMetricsChanged?.call();
    }
  }

  @override
  GestureSettings get gestureSettings =>
      _gestureSettings ?? parent.gestureSettings;
  GestureSettings? _gestureSettings;

  set gestureSettings(GestureSettings value) {
    _gestureSettings = value;
    platformDispatcher.onMetricsChanged?.call();
  }

  /// Reset configuration to real device gesture settings.
  void resetGestureSettings(bool notify) {
    _gestureSettings = null;
    if (notify) {
      platformDispatcher.onMetricsChanged?.call();
    }
  }

  @override
  void render(Scene scene, {Size? size}) {
    // Important! Draws in the entire available area of the screen.
    parent.render(scene);
  }

  @override
  void updateSemantics(SemanticsUpdate update) {
    parent.updateSemantics(update);
  }

  /// Reset all configuration to real device.
  void reset({required bool notify}) {
    resetDevicePixelRatio(notify);
    resetDisplayFeatures(notify);
    resetPadding(notify);
    resetPhysicalSize(notify);
    resetSystemGestureInsets(notify);
    resetViewInsets(notify);
    resetViewPadding(notify);
    resetGestureSettings(notify);
  }
}
