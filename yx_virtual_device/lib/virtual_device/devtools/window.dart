import 'dart:typed_data';
import 'dart:ui';

import 'flutter_view.dart';
import 'platform_dispatcher.dart';

/// Deprecated. Will be removed in a future version of Flutter.
@Deprecated('Deprecated to prepare for the upcoming multi-window support. '
    'This feature was deprecated after v3.9.0-0.1.pre.')
class VirtualWindow implements SingletonFlutterWindow {
  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  VirtualWindow.fromPlatformDispatcher({
    required this.platformDispatcher,
  });

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  final VirtualPlatformDispatcher platformDispatcher;

  VirtualFlutterView get _view => platformDispatcher.implicitView!;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  double get devicePixelRatio => _view.devicePixelRatio;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  Size get physicalSize => _view.physicalSize;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  ViewPadding get viewInsets => _view.viewInsets;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  ViewPadding get viewPadding => _view.viewPadding;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  ViewPadding get padding => _view.padding;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  GestureSettings get gestureSettings => _view.gestureSettings;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  List<DisplayFeature> get displayFeatures => _view.displayFeatures;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  ViewPadding get systemGestureInsets => _view.systemGestureInsets;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  VoidCallback? get onMetricsChanged => platformDispatcher.onMetricsChanged;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  Locale get locale => platformDispatcher.locale;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  List<Locale> get locales => platformDispatcher.locales;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  VoidCallback? get onLocaleChanged => platformDispatcher.onLocaleChanged;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  String get initialLifecycleState => platformDispatcher.initialLifecycleState;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  double get textScaleFactor => platformDispatcher.textScaleFactor;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  Brightness get platformBrightness => platformDispatcher.platformBrightness;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  VoidCallback? get onPlatformBrightnessChanged =>
      platformDispatcher.onPlatformBrightnessChanged;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  bool get alwaysUse24HourFormat => platformDispatcher.alwaysUse24HourFormat;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  VoidCallback? get onTextScaleFactorChanged =>
      platformDispatcher.onTextScaleFactorChanged;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  bool get nativeSpellCheckServiceDefined =>
      platformDispatcher.nativeSpellCheckServiceDefined;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  bool get brieflyShowPassword => platformDispatcher.brieflyShowPassword;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  FrameCallback? get onBeginFrame => platformDispatcher.onBeginFrame;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onBeginFrame(FrameCallback? callback) {
    platformDispatcher.onBeginFrame = callback;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  VoidCallback? get onDrawFrame => platformDispatcher.onDrawFrame;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onDrawFrame(VoidCallback? callback) {
    platformDispatcher.onDrawFrame = callback;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  TimingsCallback? get onReportTimings => platformDispatcher.onReportTimings;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onReportTimings(TimingsCallback? callback) {
    platformDispatcher.onReportTimings = callback;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  PointerDataPacketCallback? get onPointerDataPacket =>
      platformDispatcher.onPointerDataPacket;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onPointerDataPacket(PointerDataPacketCallback? callback) {
    platformDispatcher.onPointerDataPacket = callback;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  String get defaultRouteName => platformDispatcher.defaultRouteName;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  void scheduleFrame() {
    platformDispatcher.scheduleFrame();
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  void render(Scene scene, {Size? size}) {
    _view.render(scene, size: size);
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  bool get semanticsEnabled => platformDispatcher.semanticsEnabled;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  VoidCallback? get onSemanticsEnabledChanged =>
      platformDispatcher.onSemanticsEnabledChanged;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onSemanticsEnabledChanged(VoidCallback? callback) {
    platformDispatcher.onSemanticsEnabledChanged = callback;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  AccessibilityFeatures get accessibilityFeatures =>
      platformDispatcher.accessibilityFeatures;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  VoidCallback? get onAccessibilityFeaturesChanged =>
      platformDispatcher.onAccessibilityFeaturesChanged;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onAccessibilityFeaturesChanged(VoidCallback? callback) {
    platformDispatcher.onAccessibilityFeaturesChanged = callback;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  void updateSemantics(SemanticsUpdate update) {
    _view.updateSemantics(update);
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  void setIsolateDebugName(String name) {
    platformDispatcher.setIsolateDebugName(name);
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  void sendPlatformMessage(
    String name,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) {
    platformDispatcher.sendPlatformMessage(name, data, callback);
  }

  @override
  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  VoidCallback? get onFrameDataChanged => platformDispatcher.onFrameDataChanged;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onFrameDataChanged(VoidCallback? value) {
    platformDispatcher.onFrameDataChanged = value;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  KeyDataCallback? get onKeyData => platformDispatcher.onKeyData;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onKeyData(KeyDataCallback? value) {
    platformDispatcher.onKeyData = value;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  VoidCallback? get onSystemFontFamilyChanged =>
      platformDispatcher.onSystemFontFamilyChanged;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onSystemFontFamilyChanged(VoidCallback? value) {
    platformDispatcher.onSystemFontFamilyChanged = value;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  Locale? computePlatformResolvedLocale(List<Locale> supportedLocales) {
    return platformDispatcher.computePlatformResolvedLocale(supportedLocales);
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  FrameData get frameData => platformDispatcher.frameData;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  String? get systemFontFamily => platformDispatcher.systemFontFamily;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  int get viewId => _view.viewId;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  Display get display => _view.display;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  PlatformMessageCallback? get onPlatformMessage =>
      platformDispatcher.onPlatformMessage;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onMetricsChanged(VoidCallback? callback) {
    platformDispatcher.onMetricsChanged = callback;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onPlatformBrightnessChanged(VoidCallback? callback) {
    platformDispatcher.onPlatformBrightnessChanged = callback;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  set onTextScaleFactorChanged(VoidCallback? callback) {
    platformDispatcher.onTextScaleFactorChanged = callback;
  }

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  ViewConstraints get physicalConstraints => _view.physicalConstraints;

  @Deprecated('Deprecated to prepare for the upcoming multi-window support. '
      'This feature was deprecated after v3.9.0-0.1.pre.')
  @override
  bool get supportsShowingSystemContextMenu =>
      platformDispatcher.supportsShowingSystemContextMenu;

  @override
  set onLocaleChanged(VoidCallback? callback) {
    platformDispatcher.onLocaleChanged = callback;
  }

  @override
  set onPlatformMessage(PlatformMessageCallback? callback) {
    platformDispatcher.onPlatformMessage = callback;
  }
}
