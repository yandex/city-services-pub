import 'package:meta/meta.dart';

import '../debug_tools/debug_panel_display_type.dart';
import '../debug_tools/domain/debug_observer_readable.dart';
import '../debug_tools/domain/debug_panel_mode_notifier.dart';

/// {@template navigation_debug_configuration}
/// Groups debug-related navigation parameters.
///
/// Passed to `RouterSchema.build` to configure the optional in-app
/// debug panel: visibility control, default display layout, and the
/// observer used to surface logs inside the panel.
/// {@endtemplate}
@immutable
class NavigationDebugConfiguration {
  /// Controls whether the debug panel is enabled and initially visible.
  final DebugPanelModeNotifier? debugPanelModeNotifier;

  /// Initial display layout used by the debug panel.
  final DebugPanelDisplayType? defaultDisplayType;

  /// Observer whose logs are rendered inside the debug panel.
  final DebugObserverReadable? observerReadable;

  /// {@macro navigation_debug_configuration}
  const NavigationDebugConfiguration({
    this.debugPanelModeNotifier,
    this.defaultDisplayType,
    this.observerReadable,
  });
}
