import 'package:mocktail/mocktail.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/guard/guard_context.dart';

import 'mocks.dart';

/// Registers every mocktail fallback value used across the test suite.
///
/// Call from `setUpAll(registerFallbacks)` in every test file that uses
/// `any()` / `captureAny()` with a non-primitive type.
void registerFallbacks() {
  registerFallbackValue(
    RouteNode.fromRoute(route: const YxRoute(id: 'fallback')),
  );
  registerFallbackValue(const YxRoute(id: 'fallback'));
  registerFallbackValue(GuardContext());
  registerFallbackValue(Uri.parse('https://example.com'));
  registerFallbackValue(const RouteNodeGuardFake());
  registerFallbackValue(StackTrace.empty);
}
