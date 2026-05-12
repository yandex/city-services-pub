import 'package:flutter/widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yx_navigation/yx_navigation.dart';

/// Registers every mocktail fallback value used across the _flutter test
/// suite. Call from `setUpAll(registerFallbacks)`.
void registerFallbacks() {
  registerFallbackValue(
    RouteNode.fromRoute(route: const YxRoute(id: 'fallback')),
  );
  registerFallbackValue(const YxRoute(id: 'fallback'));
  registerFallbackValue(GuardContext());
  registerFallbackValue(Uri.parse('https://example.com'));
  registerFallbackValue(
    DeeplinkHandlerResult.navigate(
      RouteNode.fromRoute(route: const YxRoute(id: 'fallback')),
    ),
  );
  registerFallbackValue(RouteInformation(uri: Uri.parse('/fallback')));
  registerFallbackValue(
    const StrictHierarchyGuard(
      route: YxRoute(id: 'fallback'),
      declaredRoutes: [],
    ),
  );
  registerFallbackValue(StackTrace.empty);
}
