import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class DebugToolsThemeUtils {
  static String get _monospaceFontFamily {
    if (kIsWeb) {
      return 'monospace';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'monospace',
      TargetPlatform.iOS => 'Courier New',
      TargetPlatform.macOS => 'Menlo',
      TargetPlatform.windows => 'Consolas',
      TargetPlatform.linux => 'Ubuntu Mono',
      _ => 'monospace',
    };
  }

  static TextStyle get monospaceTextStyle => TextStyle(
        fontFamily: _monospaceFontFamily,
        fontWeight: switch (defaultTargetPlatform) {
          TargetPlatform.iOS => FontWeight.bold,
          _ => null,
        },
      );

  static const primaryColor = Colors.indigo;
  static final stateTreeColors = [
    const Color(0xFF3A506B), // Deep blue slate
    const Color(0xFF5D5E60), // Charcoal gray
    const Color(0xFF496A81), // Steel blue
    const Color(0xFF2C3E50), // Midnight blue
    const Color(0xFF34495E), // Wet asphalt
    const Color(0xFF445565), // Navy slate
    const Color(0xFF5D6D7E), // Dusty blue
    const Color(0xFF283747), // Dark slate
  ];
  static final errorLogColor = Colors.redAccent.shade400.withValues(alpha: 0.3);

  static String formatTimestamp(DateTime timestamp) {
    final time = timestamp.toLocal();
    return '${time.hour}:${time.minute}:${time.second}:${time.millisecond}';
  }
}
