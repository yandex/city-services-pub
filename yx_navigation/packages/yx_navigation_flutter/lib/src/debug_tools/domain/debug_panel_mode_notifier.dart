import 'package:flutter/material.dart';

/// {@template debug_panel_mode_notifier}
/// Controls whether the in-app navigation debug panel is enabled.
///
/// Exposes the current `enableDebugPanel` flag via [ChangeNotifier] so the
/// panel can be shown or hidden dynamically at runtime. Instances are
/// typically passed to the router through [NavigationDebugConfiguration].
/// {@endtemplate}
class DebugPanelModeNotifier extends ChangeNotifier {
  /// Whether the debug panel is visible when first mounted.
  final bool isInitiallyVisible;

  /// Creates a [DebugPanelModeNotifier].
  ///
  /// {@macro debug_panel_mode_notifier}
  ///
  /// [enableDebugPanel] is the initial state of the panel; pass `false` to
  /// keep it disabled until [setEnableDebugPanel] flips it on.
  DebugPanelModeNotifier({
    required bool enableDebugPanel,
    this.isInitiallyVisible = false,
  }) : _enableDebugPanel = enableDebugPanel;

  bool _enableDebugPanel;

  /// Whether the debug panel is currently enabled.
  bool get enableDebugPanel => _enableDebugPanel;

  /// Updates the enabled state and notifies listeners.
  void setEnableDebugPanel(bool enable) {
    _enableDebugPanel = enable;
    notifyListeners();
  }
}
