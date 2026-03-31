import 'dart:ui';

import 'platform_dispatcher.dart';

/// A configurable display that a [FlutterView] renders on.
class VirtualDisplay implements Display {
  VirtualDisplay(
    VirtualPlatformDispatcher platformDispatcher,
    Display display,
  )   : _platformDispatcher = platformDispatcher,
        _display = display;

  final Display _display;
  final VirtualPlatformDispatcher _platformDispatcher;

  @override
  int get id => _display.id;

  @override
  double get devicePixelRatio => vDevicePixelRatio ?? _display.devicePixelRatio;
  double? vDevicePixelRatio;

  set devicePixelRatio(double value) {
    vDevicePixelRatio = value;
    _platformDispatcher.onMetricsChanged?.call();
  }

  /// Reset configuration to real device pixel ratio.
  void resetDevicePixelRatio(bool notify) {
    vDevicePixelRatio = null;
    if (notify) {
      _platformDispatcher.onMetricsChanged?.call();
    }
  }

  @override
  double get refreshRate => _refreshRate ?? _display.refreshRate;
  double? _refreshRate;

  set refreshRate(double value) {
    _refreshRate = value;
    _platformDispatcher.onMetricsChanged?.call();
  }

  /// Reset configuration to real device refresh rate.
  void resetRefreshRate(bool notify) {
    _refreshRate = null;
    if (notify) {
      _platformDispatcher.onMetricsChanged?.call();
    }
  }

  @override
  Size get size => _size ?? _display.size;
  Size? _size;

  set size(Size value) {
    _size = value;
    _platformDispatcher.onMetricsChanged?.call();
  }

  /// Reset configuration to real device size.
  void resetSize(bool notify) {
    _size = null;
    if (notify) {
      _platformDispatcher.onMetricsChanged?.call();
    }
  }

  /// Reset all display configuration to real device.
  void reset(bool notify) {
    resetDevicePixelRatio(notify);
    resetRefreshRate(notify);
    resetSize(notify);
  }
}
