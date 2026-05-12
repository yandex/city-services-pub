import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/back_button_handler.dart';
import 'package:yx_navigation_flutter/src/router/active_route_controller_provider.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

// internal test double, not exported
class _StubActiveRouteController implements ActiveRouteController {
  _StubActiveRouteController({required YxRoute activeRoute})
      : _activeRoute = activeRoute;

  final YxRoute _activeRoute;

  @override
  YxRoute? get activeRoute => _activeRoute;

  @override
  Stream<YxRoute?> get activeRouteStream => const Stream<YxRoute?>.empty();

  @override
  bool isRouteActive(YxRoute route) => route == _activeRoute;

  @override
  void setActiveRoute(YxRoute route) {}
}

void main() {
  setUpAll(registerFallbacks);

  group('DefaultBackButtonHandler', () {
    testWidgets(
      'delegates maybePop to the navigator when no controller is present',
      (tester) async {
        // arrange
        const actualHandler = DefaultBackButtonHandler();
        final actualNavigatorKey = GlobalKey<NavigatorState>();
        final actualNode = makeNode();

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: actualNavigatorKey,
            home: const Scaffold(body: SizedBox.shrink()),
          ),
        );

        final context = actualNavigatorKey.currentContext!;
        final navigator = actualNavigatorKey.currentState!;

        // act
        final actualResult = await actualHandler.call(
          context,
          actualNode,
          navigator,
        );

        // assert
        expect(actualResult, isFalse);
      },
    );

    testWidgets(
      'returns false without popping when the underlying ModalRoute is not '
      'current (another page is on top)',
      (tester) async {
        // arrange
        const actualHandler = DefaultBackButtonHandler();
        final actualNavigatorKey = GlobalKey<NavigatorState>();
        final actualNode = makeNode();
        BuildContext? homeContext;

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: actualNavigatorKey,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  homeContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        // push a second page — `homeContext` now belongs to a ModalRoute
        // whose `isCurrent` is false.
        unawaited(
          actualNavigatorKey.currentState!.push<void>(
            MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: SizedBox.shrink()),
            ),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // sanity check — home context is not current anymore.
        expect(ModalRoute.of(homeContext!)?.isCurrent, isFalse);

        // act
        final actualResult = await actualHandler.call(
          homeContext!,
          actualNode,
          actualNavigatorKey.currentState!,
        );

        // assert: contract — handler refuses to pop because the context's
        // ModalRoute is not current.
        expect(actualResult, isFalse);
        // still has two routes — nothing was popped by the handler.
        expect(find.byType(MaterialPageRoute), findsNothing);
      },
    );

    testWidgets(
      'returns false without popping when the current tab is inactive',
      (tester) async {
        // arrange
        const actualHandler = DefaultBackButtonHandler();
        final actualNavigatorKey = GlobalKey<NavigatorState>();
        const routeForThisOutlet = YxRoute(id: 'this_tab');
        const routeForActiveTab = YxRoute(id: 'other_tab');
        final actualNode = makeNode(route: routeForThisOutlet);
        BuildContext? capturedContext;

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: actualNavigatorKey,
            home: ActiveRouteControllerProvider(
              controller: _StubActiveRouteController(
                activeRoute: routeForActiveTab,
              ),
              child: Scaffold(
                body: Builder(
                  builder: (context) {
                    capturedContext = context;
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        );

        // act
        final actualResult = await actualHandler.call(
          capturedContext!,
          actualNode,
          actualNavigatorKey.currentState!,
        );

        // assert: contract — while the controller reports a different tab
        // as active, the handler does not consume the back press.
        expect(actualResult, isFalse);
      },
    );
  });
}
