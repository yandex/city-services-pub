part of '../base_scope_container.dart';

/// Returns a short description of an [object]'s runtime type suitable for
/// `toString()` output and diagnostics.
///
/// In debug builds (where asserts are enabled) this returns the real
/// `object.runtimeType.toString()`, giving the fully-qualified generic type
/// (e.g. `ScopeStateHolder<FooScope>`).
///
/// In release builds `runtimeType.toString()` is unreliable: Dart minifies
/// type names, so it may return something like `minified:H<dynamic>` instead of
/// the real type. Since these diagnostics feed production non-fatals, we fall
/// back to the hardcoded [optimizedValue] there so the log still names the type.
///
/// This mirrors `objectRuntimeType` from `package:flutter/foundation`, but is
/// implemented in pure Dart so that the core `yx_scope` package stays
/// Flutter-free.
///
/// See also:
///  * https://api.flutter.dev/flutter/foundation/objectRuntimeType.html
///  * Dart lint `no_runtimeType_toString`.
String objectRuntimeType(Object? object, String optimizedValue) {
  assert(() {
    optimizedValue = object.runtimeType.toString();
    return true;
  }(), '');
  return optimizedValue;
}
