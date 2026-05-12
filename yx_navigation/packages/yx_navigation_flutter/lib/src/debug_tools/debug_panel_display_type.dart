/// {@template debug_panel_display_type}
/// Layout used to render the in-app debug panel.
///
/// Controls how the debug panel overlay is arranged relative to the
/// application's content. `overlay*` values render the panel on top of the
/// app, `split*` values share the available space with the app, and
/// [fullscreen] replaces the content entirely.
/// {@endtemplate}
enum DebugPanelDisplayType {
  /// Overlay panel aligned to the leading edge.
  overlayLeading('Overlay Leading'),

  /// Overlay panel aligned to the trailing edge.
  overlayTrailing('Overlay Trailing'),

  /// Split layout with the panel on the leading side.
  splitLeading('Split Leading'),

  /// Split layout with the panel on the trailing side.
  splitTrailing('Split Trailing'),

  /// Split layout with the panel on top.
  splitTop('Split Top'),

  /// Split layout with the panel on the bottom.
  splitBottom('Split Bottom'),

  /// Panel takes the entire screen.
  fullscreen('Fullscreen');

  /// Human-readable label describing this layout.
  final String description;

  const DebugPanelDisplayType(this.description);
}
