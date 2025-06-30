import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// This exception must be throw in cases when
// a consumer of this package uses it
// in some inappropriate way.
class FlutterScopeError extends FlutterError {
  FlutterScopeError.fromParts(List<DiagnosticsNode> diagnostics)
      : super.fromParts(diagnostics);

  factory FlutterScopeError(String message) {
    final List<String> lines = message.split('\n');
    return FlutterScopeError.fromParts(<DiagnosticsNode>[
      ErrorSummary(lines.first),
      ...lines
          .skip(1)
          .map<DiagnosticsNode>((String line) => ErrorDescription(line)),
    ]);
  }
}
