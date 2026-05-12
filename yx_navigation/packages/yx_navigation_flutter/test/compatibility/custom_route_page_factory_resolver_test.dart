import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/compatibility/custom_route_page_factory_resolver.dart';
import 'package:yx_navigation_flutter/src/compatibility/navigator_compatibility_overrides.dart';
import 'package:yx_navigation_flutter/src/compatibility/route_node_compatibility_extension.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

/// Resolver that records every call to [resolvePage] so the test can
/// inspect the forwarded completer and route.
class _RecordingResolver extends CustomRoutePageFactoryResolver {
  _RecordingResolver();

  int resolveCalls = 0;
  Completer<Object?>? lastCompleter;
  Route<Object?>? lastRoute;
  LocalKey? lastKey;

  @override
  bool hasResolverFor<T>(Route<T> route) => true;

  @override
  Page<Object?> resolvePage<T>({
    required Completer<T?> routeCompleter,
    required Route<T> route,
    required LocalKey key,
  }) {
    resolveCalls++;
    lastCompleter = routeCompleter as Completer<Object?>;
    lastRoute = route as Route<Object?>;
    lastKey = key;
    return MaterialPage<Object?>(key: key, child: const SizedBox.shrink());
  }
}

Completer<Object?>? _nullCompleter() => null;

void main() {
  setUpAll(registerFallbacks);

  group('CustomRoutePageFactoryResolver', () {
    testWidgets(
      'custom resolver is consulted BEFORE built-in route handlers '
      '(priority contract)',
      (tester) async {
        // arrange: a MaterialPageRoute would normally be resolved by the
        // built-in MaterialPageRoute branch, but our custom resolver claims
        // it first and returns a MaterialPage sentinel we can identify.
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
        );
        final resolver = _RecordingResolver();
        final actualOverrides = NavigatorCompatibilityOverrides(
          customRoutePageFactoryResolver: resolver,
        );
        final pushed = <RouteNode>[];
        final controller = NavigationControllerMock();
        when(() => controller.pushNode(any())).thenAnswer(
          (invocation) =>
              pushed.add(invocation.positionalArguments[0] as RouteNode),
        );
        when(() => controller.state).thenReturn(
          RouteNode.fromRoute(route: const YxRoute(id: 'root')),
        );
        final route = MaterialPageRoute<Object?>(
          builder: (_) => const SizedBox.shrink(),
        );

        // act
        unawaited(
          actualOverrides.push!<Object?>(
            route: route,
            context: tester.element(find.byType(Scaffold)),
            navigator: _FakeNavigator(),
            popCompleterProvider: _nullCompleter,
            navigationController: controller,
          ),
        );

        // assert: resolver ran — meaning it was consulted BEFORE the built-in
        // MaterialPageRoute branch.
        expect(resolver.resolveCalls, equals(1));
        expect(resolver.lastRoute, same(route));
        // The resulting page is the one produced by the custom resolver
        // (MaterialPage), not the built-in ProxyMaterialPage.
        expect(pushed.single.pageFactory, isA<MaterialPage<Object?>>());
        expect(pushed.single.pageFactory, isNot(isA<ProxyMaterialPage>()));
      },
    );

    testWidgets(
      'resolvePage receives a real completer; completing it resolves the '
      'push future',
      (tester) async {
        // arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
        );
        final resolver = _RecordingResolver();
        final actualOverrides = NavigatorCompatibilityOverrides(
          customRoutePageFactoryResolver: resolver,
        );
        final controller = NavigationControllerMock();
        when(() => controller.pushNode(any())).thenAnswer((_) {});
        when(() => controller.state).thenReturn(
          RouteNode.fromRoute(route: const YxRoute(id: 'root')),
        );
        final route = MaterialPageRoute<Object?>(
          builder: (_) => const SizedBox.shrink(),
        );

        // act
        final pushFuture = actualOverrides.push!<Object?>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _nullCompleter,
          navigationController: controller,
        );

        // The completer forwarded to the resolver is the same one whose
        // future is returned from push. Completing it surfaces a result.
        resolver.lastCompleter!.complete('resolved');

        // assert
        expect(await pushFuture, equals('resolved'));
      },
    );
  });
}

/// Minimal NavigatorState stub.
class _FakeNavigator extends Fake implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      '_FakeNavigator';
}
