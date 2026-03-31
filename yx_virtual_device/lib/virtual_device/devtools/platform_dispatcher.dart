import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'display.dart';
import 'flutter_view.dart';

/// Platform event dispatcher singleton.
///
/// The most basic interface to the host operating system's interface.
///
/// This is the central entry point for platform messages and configuration
/// events from the platform.
///
/// It exposes the core scheduler API, the input event callback, the graphics
/// drawing API, and other such core services.
///
/// It manages the list of the application's [views] as well as the
/// [configuration] of various platform attributes.
class VirtualPlatformDispatcher implements PlatformDispatcher {
  VirtualPlatformDispatcher({
    required PlatformDispatcher platformDispatcher,
  }) : parent = platformDispatcher {
    _updateViewsAndDisplays();
    parent.onMetricsChanged = _handleMetricsChanged;
    parent.onViewFocusChange = _handleViewFocusChanged;
  }

  /// Real [PlatformDispatcher].
  final PlatformDispatcher parent;

  @override
  VirtualFlutterView? get implicitView {
    return parent.implicitView != null
        ? _virtualViews[parent.implicitView!.viewId]!
        : null;
  }

  final Map<int, VirtualFlutterView> _virtualViews = {};
  final Map<int, VirtualDisplay> _virtualDisplays = {};

  @override
  VoidCallback? get onMetricsChanged => parent.onMetricsChanged;
  VoidCallback? _onMetricsChanged;

  @override
  set onMetricsChanged(VoidCallback? callback) {
    _onMetricsChanged = callback;
  }

  void _handleMetricsChanged() {
    _updateViewsAndDisplays();
    _onMetricsChanged?.call();
  }

  @override
  ViewFocusChangeCallback? get onViewFocusChange => parent.onViewFocusChange;
  ViewFocusChangeCallback? _onViewFocusChange;

  @override
  set onViewFocusChange(ViewFocusChangeCallback? callback) {
    _onViewFocusChange = callback;
  }

  void _handleViewFocusChanged(ViewFocusEvent event) {
    _updateViewsAndDisplays();
    _onViewFocusChange?.call(event);
  }

  @override
  Locale get locale => _locale ?? parent.locale;
  Locale? _locale;

  set locale(Locale locale) {
    _locale = locale;
    onLocaleChanged?.call();
  }

  /// Reset configuration to real device locale.
  void resetLocale() {
    _locale = null;
    onLocaleChanged?.call();
  }

  @override
  List<Locale> get locales => _locales ?? parent.locales;
  List<Locale>? _locales;

  set locales(List<Locale> locales) {
    _locales = locales;
    onLocaleChanged?.call();
  }

  /// Reset configuration to real device locales.
  void resetLocales() {
    _locales = null;
    onLocaleChanged?.call();
  }

  @override
  VoidCallback? get onLocaleChanged => parent.onLocaleChanged;

  @override
  set onLocaleChanged(VoidCallback? callback) {
    parent.onLocaleChanged = callback;
  }

  @override
  String get initialLifecycleState =>
      _initialLifecycleState ?? parent.initialLifecycleState;
  String? _initialLifecycleState = null;

  set initialLifecycleState(String initialState) {
    _initialLifecycleState = initialState;
  }

  /// Reset configuration to real device initial state.
  void resetInitialLifecycleState() {
    _initialLifecycleState = null;
  }

  @override
  double get textScaleFactor => _textScaleFactor ?? parent.textScaleFactor;
  double? _textScaleFactor;

  set textScaleFactor(double textScaleFactor) {
    _textScaleFactor = textScaleFactor;
    onTextScaleFactorChanged?.call();
  }

  /// Reset configuration to real device text scale factor.
  void resetTextScaleFactor() {
    _textScaleFactor = null;
    onTextScaleFactorChanged?.call();
  }

  @override
  Brightness get platformBrightness =>
      _platformBrightness ?? parent.platformBrightness;
  Brightness? _platformBrightness;

  @override
  VoidCallback? get onPlatformBrightnessChanged =>
      parent.onPlatformBrightnessChanged;

  @override
  set onPlatformBrightnessChanged(VoidCallback? callback) {
    parent.onPlatformBrightnessChanged = callback;
  }

  set platformBrightness(Brightness platformBrightness) {
    _platformBrightness = platformBrightness;
    onPlatformBrightnessChanged?.call();
  }

  /// Reset configuration to real device platform brightness.
  void resetPlatformBrightness() {
    _platformBrightness = null;
    onPlatformBrightnessChanged?.call();
  }

  @override
  bool get alwaysUse24HourFormat =>
      _alwaysUse24HourFormat ?? parent.alwaysUse24HourFormat;
  bool? _alwaysUse24HourFormat;

  set alwaysUse24HourFormat(bool alwaysUse24HourFormat) {
    _alwaysUse24HourFormat = alwaysUse24HourFormat;
  }

  /// Reset configuration to real device feature.
  void resetAlwaysUse24Hour() {
    _alwaysUse24HourFormat = null;
  }

  @override
  VoidCallback? get onTextScaleFactorChanged => parent.onTextScaleFactorChanged;

  @override
  set onTextScaleFactorChanged(VoidCallback? callback) {
    parent.onTextScaleFactorChanged = callback;
  }

  @override
  bool get nativeSpellCheckServiceDefined =>
      _nativeSpellCheckServiceDefined ?? parent.nativeSpellCheckServiceDefined;
  bool? _nativeSpellCheckServiceDefined;

  set nativeSpellCheckServiceDefined(bool nativeSpellCheckServiceDefined) {
    _nativeSpellCheckServiceDefined = nativeSpellCheckServiceDefined;
  }

  /// Reset configuration to real device feature.
  void resetNativeSpellCheckServiceDefined() {
    _nativeSpellCheckServiceDefined = null;
  }

  @override
  bool get supportsShowingSystemContextMenu =>
      _supportsShowingSystemContextMenu ??
      parent.supportsShowingSystemContextMenu;
  bool? _supportsShowingSystemContextMenu;

  set supportsShowingSystemContextMenu(bool value) {
    _supportsShowingSystemContextMenu = value;
  }

  /// Reset configuration to real device feature.
  void resetSupportsShowingSystemContextMenu() {
    _supportsShowingSystemContextMenu = null;
  }

  @override
  bool get brieflyShowPassword =>
      _brieflyShowPassword ?? parent.brieflyShowPassword;
  bool? _brieflyShowPassword;

  set brieflyShowPassword(bool brieflyShowPassword) {
    _brieflyShowPassword = brieflyShowPassword;
  }

  /// Reset configuration to real device feature.
  void resetBrieflyShowPassword() {
    _brieflyShowPassword = null;
  }

  @override
  FrameCallback? get onBeginFrame => parent.onBeginFrame;

  @override
  set onBeginFrame(FrameCallback? callback) {
    parent.onBeginFrame = callback;
  }

  @override
  VoidCallback? get onDrawFrame => parent.onDrawFrame;

  @override
  set onDrawFrame(VoidCallback? callback) {
    parent.onDrawFrame = callback;
  }

  @override
  TimingsCallback? get onReportTimings => parent.onReportTimings;

  @override
  set onReportTimings(TimingsCallback? callback) {
    parent.onReportTimings = callback;
  }

  @override
  PointerDataPacketCallback? get onPointerDataPacket =>
      parent.onPointerDataPacket;

  @override
  set onPointerDataPacket(PointerDataPacketCallback? callback) {
    parent.onPointerDataPacket = callback;
  }

  @override
  String get defaultRouteName => _defaultRouteName ?? parent.defaultRouteName;
  String? _defaultRouteName;

  set defaultRouteName(String defaultRouteName) {
    _defaultRouteName = defaultRouteName;
  }

  /// Reset configuration to real device feature.
  void resetDefaultRouteName() {
    _defaultRouteName = null;
  }

  @override
  void scheduleFrame() {
    parent.scheduleFrame();
  }

  @override
  bool get semanticsEnabled => _semanticsEnabled ?? parent.semanticsEnabled;
  bool? _semanticsEnabled;

  set semanticsEnabled(bool semanticsEnabled) {
    _semanticsEnabled = semanticsEnabled;
    onSemanticsEnabledChanged?.call();
  }

  /// Reset configuration to real device feature.
  void resetSemanticsEnabled() {
    _semanticsEnabled = null;
    onSemanticsEnabledChanged?.call();
  }

  @override
  VoidCallback? get onSemanticsEnabledChanged =>
      parent.onSemanticsEnabledChanged;

  @override
  set onSemanticsEnabledChanged(VoidCallback? callback) {
    parent.onSemanticsEnabledChanged = callback;
  }

  @override
  SemanticsActionEventCallback? get onSemanticsActionEvent =>
      parent.onSemanticsActionEvent;

  @override
  set onSemanticsActionEvent(SemanticsActionEventCallback? callback) {
    parent.onSemanticsActionEvent = callback;
  }

  @override
  AccessibilityFeatures get accessibilityFeatures =>
      _accessibilityFeatures ?? parent.accessibilityFeatures;
  AccessibilityFeatures? _accessibilityFeatures;

  set accessibilityFeatures(AccessibilityFeatures accessibilityFeatures) {
    _accessibilityFeatures = accessibilityFeatures;
    onAccessibilityFeaturesChanged?.call();
  }

  /// Reset configuration to real device feature.
  void resetAccessibilityFeatures() {
    _accessibilityFeatures = null;
    onAccessibilityFeaturesChanged?.call();
  }

  @override
  VoidCallback? get onAccessibilityFeaturesChanged =>
      parent.onAccessibilityFeaturesChanged;

  @override
  set onAccessibilityFeaturesChanged(VoidCallback? callback) {
    parent.onAccessibilityFeaturesChanged = callback;
  }

  @override
  void setIsolateDebugName(String name) {
    parent.setIsolateDebugName(name);
  }

  @override
  void sendPlatformMessage(
    String name,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) {
    parent.sendPlatformMessage(name, data, callback);
  }

  /// Reset all configuration to real device.
  void reset() {
    resetAccessibilityFeatures();
    resetAlwaysUse24Hour();
    resetDefaultRouteName();
    resetPlatformBrightness();
    resetLocale();
    resetLocales();
    resetSemanticsEnabled();
    resetTextScaleFactor();
    resetNativeSpellCheckServiceDefined();
    resetBrieflyShowPassword();
    resetSupportsShowingSystemContextMenu();
    resetInitialLifecycleState();
    resetSystemFontFamily();
  }

  @override
  VoidCallback? get onFrameDataChanged => parent.onFrameDataChanged;

  @override
  set onFrameDataChanged(VoidCallback? value) {
    parent.onFrameDataChanged = value;
  }

  @override
  KeyDataCallback? get onKeyData => parent.onKeyData;

  @override
  set onKeyData(KeyDataCallback? onKeyData) {
    parent.onKeyData = onKeyData;
  }

  @override
  VoidCallback? get onPlatformConfigurationChanged =>
      parent.onPlatformConfigurationChanged;

  @override
  set onPlatformConfigurationChanged(
      VoidCallback? onPlatformConfigurationChanged) {
    parent.onPlatformConfigurationChanged = onPlatformConfigurationChanged;
  }

  @override
  Locale? computePlatformResolvedLocale(List<Locale> supportedLocales) =>
      parent.computePlatformResolvedLocale(supportedLocales);

  @override
  ByteData? getPersistentIsolateData() => parent.getPersistentIsolateData();

  @override
  Iterable<VirtualFlutterView> get views => _virtualViews.values;

  @override
  FlutterView? view({required int id}) => _virtualViews[id];

  @override
  Iterable<VirtualDisplay> get displays => _virtualDisplays.values;

  // It helps to change the display and view to a virtual wrapper.
  void _updateViewsAndDisplays() {
    final List<Object> extraDisplayKeys = <Object>[..._virtualDisplays.keys];
    for (final Display display in parent.displays) {
      extraDisplayKeys.remove(display.id);
      if (!_virtualDisplays.containsKey(display.id)) {
        _virtualDisplays[display.id] = VirtualDisplay(this, display);
      }
    }
    extraDisplayKeys.forEach(_virtualDisplays.remove);

    final List<Object> extraViewKeys = <Object>[..._virtualViews.keys];
    for (final FlutterView view in parent.views) {
      late final VirtualDisplay display;
      try {
        final Display realDisplay = view.display;
        if (_virtualDisplays.containsKey(realDisplay.id)) {
          display = _virtualDisplays[view.display.id]!;
        } else {
          display = _UnsupportedDisplay(
            this,
            view,
            'PlatformDispatcher did not contain a Display with id ${realDisplay.id}, '
            'which was expected by FlutterView ($view)',
          );
        }
      } catch (error) {
        display = _UnsupportedDisplay(this, view, error);
      }

      extraViewKeys.remove(view.viewId);
      if (!_virtualViews.containsKey(view.viewId)) {
        _virtualViews[view.viewId] = VirtualFlutterView(
          view: view,
          platformDispatcher: this,
          display: display,
        );
      }
    }

    extraViewKeys.forEach(_virtualViews.remove);
  }

  @override
  ErrorCallback? get onError => parent.onError;

  @override
  set onError(ErrorCallback? value) {
    parent.onError;
  }

  @override
  VoidCallback? get onSystemFontFamilyChanged =>
      parent.onSystemFontFamilyChanged;

  @override
  set onSystemFontFamilyChanged(VoidCallback? value) {
    parent.onSystemFontFamilyChanged = value;
  }

  @override
  FrameData get frameData => parent.frameData;

  @override
  void registerBackgroundIsolate(RootIsolateToken token) {
    parent.registerBackgroundIsolate(token);
  }

  @override
  void requestDartPerformanceMode(DartPerformanceMode mode) {
    parent.requestDartPerformanceMode(mode);
  }

  @override
  String? get systemFontFamily {
    return _forceSystemFontFamilyToBeNull
        ? null
        : _systemFontFamily ?? parent.systemFontFamily;
  }

  String? _systemFontFamily;
  bool _forceSystemFontFamilyToBeNull = false;

  set systemFontFamily(String? value) {
    _systemFontFamily = value;
    if (value == null) {
      _forceSystemFontFamilyToBeNull = true;
    }
    onSystemFontFamilyChanged?.call();
  }

  void resetSystemFontFamily() {
    _systemFontFamily = null;
    _forceSystemFontFamilyToBeNull = false;
    onSystemFontFamilyChanged?.call();
  }

  @override
  void updateSemantics(SemanticsUpdate update) {
    parent.updateSemantics(update);
  }

  @override
  PlatformMessageCallback? get onPlatformMessage => parent.onPlatformMessage;

  @override
  set onPlatformMessage(PlatformMessageCallback? callback) {
    parent.onPlatformMessage = callback;
  }

  @override
  void requestViewFocusChange({
    required int viewId,
    required ViewFocusState state,
    required ViewFocusDirection direction,
  }) {
    parent.requestViewFocusChange(
      viewId: viewId,
      state: state,
      direction: direction,
    );
  }

  @override
  double scaleFontSize(double unscaledFontSize) =>
      parent.scaleFontSize(unscaledFontSize);

  @override
  void scheduleWarmUpFrame({
    required VoidCallback beginFrame,
    required VoidCallback drawFrame,
  }) {
    parent.scheduleWarmUpFrame(
      beginFrame: beginFrame,
      drawFrame: drawFrame,
    );
  }

  @override
  void sendPortPlatformMessage(
    String name,
    ByteData? data,
    int identifier,
    Object port,
  ) {
    // Fix for Flutter Web.
    final sendPort = port as SendPort;
    parent.sendPortPlatformMessage(
      name,
      data,
      identifier,
      sendPort,
    );
  }
}

class _UnsupportedDisplay implements VirtualDisplay {
  _UnsupportedDisplay(this.parent, this._view, this.error);

  final FlutterView _view;
  final Object? error;

  final VirtualPlatformDispatcher parent;

  @override
  double get devicePixelRatio => vDevicePixelRatio ?? _view.devicePixelRatio;
  double? vDevicePixelRatio;

  @override
  set devicePixelRatio(double value) {
    vDevicePixelRatio = value;
    parent.onMetricsChanged?.call();
  }

  @override
  void resetDevicePixelRatio(bool notify) {
    vDevicePixelRatio = null;
    if (notify) {
      parent.onMetricsChanged?.call();
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnsupportedError(
      'The Display API is unsupported in this context. '
      'As of the last metrics change on PlatformDispatcher, this was the error '
      'given when trying to prepare the display for testing: $error',
    );
  }
}
