import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../device/info.dart';
import 'platform_dispatcher.dart';
import 'render_view.dart';
import 'transforms.dart';
import 'view_padding.dart';
import 'window.dart';

/// A concrete binding for applications based on the Widgets framework.
///
/// This is the glue that binds the framework to the Flutter engine.
class VirtualWidgetsFlutterBinding extends BindingBase
    with
        GestureBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        WidgetsBinding {
  static VirtualWidgetsFlutterBinding get virtualBinding {
    return WidgetsBinding.instance as VirtualWidgetsFlutterBinding;
  }

  /// Returns an instance of the [WidgetsBinding], creating and
  /// initializing it if necessary. If one is created, it will be a
  /// [VirtualWidgetsFlutterBinding]. If one was previously initialized, then
  /// it will at least implement [WidgetsBinding].
  ///
  /// Call before calling [runApp].
  static WidgetsBinding ensureInitialized() {
    VirtualWidgetsFlutterBinding();
    return WidgetsBinding.instance;
  }

  /// Synchronize with device orientation.
  bool autoOrientation = true;

  Orientation _orientation = Orientation.portrait;

  /// Current device orientation.
  Orientation get orientation => _orientation;

  /// Programmatically set device orientation.
  /// Can be changed implicitly while enabled [autoOrientation].
  set orientation(Orientation value) {
    if (_orientation != value) {
      _orientation = value;
      _updateSizeAndPadding();
      renderView.orientation = value;
    }
  }

  DeviceInfo? _device;

  /// Current device information.
  DeviceInfo? get device => _device;

  /// Programmatically set virtual device.
  /// If you pass null, the real configuration will be used.
  set device(DeviceInfo? value) {
    if (_device?.identifier != value?.identifier) {
      _device = value;
      renderView.device = value;
      _updateVirtualOrientation();
      _updateSizeAndPadding();
    }
  }

  // Function that updates physical parameters
  // according to the device configuration.
  void _updateSizeAndPadding() {
    final device = this.device;
    if (device != null) {
      final size = device.screenSizeOn(orientation) * device.pixelRatio;
      final padding = VirtualViewPadding.fromEdgeInsets(
          ((_orientation == Orientation.portrait
                      ? device.safeAreas
                      : device.rotatedSafeAreas) ??
                  device.safeAreas) *
              device.pixelRatio);

      platformDispatcher.implicitView
        ?..physicalSize = size
        ..devicePixelRatio = device.pixelRatio
        ..padding = padding
        ..viewPadding = padding;
      platformDispatcher.onMetricsChanged?.call();
    } else {
      platformDispatcher.implicitView?.reset(notify: false);
      platformDispatcher.onMetricsChanged?.call();
    }
    reassembleApplication();
  }

  @override
  late VirtualPlatformDispatcher platformDispatcher = VirtualPlatformDispatcher(
    platformDispatcher: super.platformDispatcher,
  );

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  late VirtualWindow window = VirtualWindow.fromPlatformDispatcher(
    platformDispatcher: platformDispatcher,
  );

  @override
  late VirtualRenderView renderView = VirtualRenderView(
    view: platformDispatcher.implicitView!,
  );

  @override
  void handlePointerEvent(PointerEvent event) {
    if (locked) {
      return;
    }

    final device = this.device;
    if (device == null) {
      super.handlePointerEvent(event);
      return;
    }

    final flutterView = platformDispatcher.implicitView!;
    final realPixelRatio = flutterView.parent.devicePixelRatio;
    final virtualPixelRatio = flutterView.devicePixelRatio;
    final scale = virtualPixelRatio / realPixelRatio;

    event = event.copyWith(
      position: event.position * scale,
      delta: event.delta * scale,
    );

    final screenArea = VirtualTransforms.screenDestinationRect(
      device,
      orientation,
    );

    if (!screenArea.contains(event.position)) {
      return;
    }

    final relativePosition = Offset(
      (event.position.dx - screenArea.left) / screenArea.width,
      (event.position.dy - screenArea.top) / screenArea.height,
    );

    final relativeDelta = Offset(
      event.delta.dx / screenArea.width,
      event.delta.dy / screenArea.height,
    );

    final screenSize = device.screenSizeOn(orientation);

    final transformedEvent = event.copyWith(
      position: Offset(
        relativePosition.dx * screenSize.width,
        relativePosition.dy * screenSize.height,
      ),
      delta: Offset(
        relativeDelta.dx * screenSize.width,
        relativeDelta.dy * screenSize.height,
      ),
    );

    super.handlePointerEvent(transformedEvent);
  }

  void _updateVirtualOrientation() {
    final size = platformDispatcher.implicitView!.parent.physicalSize;
    final isLandscape = size.width > size.height;
    final currentOrientation =
        isLandscape ? Orientation.landscape : Orientation.portrait;

    // Allow only auto orientation
    if (autoOrientation) {
      orientation = currentOrientation;
    }
  }

  @override
  void handleMetricsChanged() {
    _updateVirtualOrientation();
    super.handleMetricsChanged();
  }
}
