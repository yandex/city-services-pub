import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_declaration.dart';
import 'package:yx_navigation_flutter/src/base/route_declaration_resolver.dart';
import 'package:yx_navigation_flutter/src/base/route_node_builder.dart';
import 'package:yx_navigation_flutter/src/config/navigation_config_provider.dart';
import 'package:yx_navigation_flutter/src/router/yx_router_delegate.dart';

import '../helpers/async.dart';
import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

BaseRouteNodeBuilder _builderForRoute(YxRoute route) => BaseRouteNodeBuilder(
      routeDeclarationResolver: RouteDeclarationResolver(
        declarations: [
          RouteDeclaration.routeBuilder(
            route: route,
            routeBuilder: RouteBuilder<Object?>.widget(
              builder: (context, node) => Text('route:${node.route.id}'),
            ),
          ),
        ],
      ),
    );

void main() {
  setUpAll(registerFallbacks);

  group('YxRouterDelegate', () {
    test('currentConfiguration returns state manager state', () {
      // arrange
      final expectedNode = makeNode(route: makeRoute(id: 'home'));
      final stateManager = RouteNodeStateManager(routeNode: expectedNode);
      addTearDown(stateManager.close);
      final actualDelegate = YxRouterDelegate(
        stateManager: stateManager,
        routeNodeBuilder: RouteNodeBuilderMock(),
      );
      addTearDown(actualDelegate.dispose);

      // act/assert
      expect(actualDelegate.currentConfiguration, same(expectedNode));
    });

    testAsync(
        'setNewRoutePath notifies listeners so downstream widgets can rebuild',
        (fa) {
      // arrange
      final initialNode = makeNode(route: makeRoute(id: 'root'));
      final stateManager = RouteNodeStateManager(routeNode: initialNode);
      addTearDown(stateManager.close);
      final actualDelegate = YxRouterDelegate(
        stateManager: stateManager,
        routeNodeBuilder: RouteNodeBuilderMock(),
      );
      addTearDown(actualDelegate.dispose);
      var notifyCount = 0;
      actualDelegate.addListener(() => notifyCount++);
      final expectedConfig = makeNode(route: makeRoute(id: 'target'));

      // act
      actualDelegate.setNewRoutePath(expectedConfig);
      fa.flushMicrotasks();

      // assert: exactly one notification per path change (guards against
      // regressions that introduce duplicate rebuilds).
      expect(notifyCount, equals(1));
    });

    testAsync('notifyListeners fires when state manager mutates', (fa) {
      // arrange
      final initialNode = makeNode();
      final stateManager = RouteNodeStateManager(routeNode: initialNode);
      addTearDown(stateManager.close);
      final actualDelegate = YxRouterDelegate(
        stateManager: stateManager,
        routeNodeBuilder: RouteNodeBuilderMock(),
      );
      addTearDown(actualDelegate.dispose);
      var notifyCount = 0;
      actualDelegate.addListener(() => notifyCount++);

      // act
      stateManager.mutate(
        (state) => makeNode(route: makeRoute(id: 'new')),
      );
      fa.flushMicrotasks();

      // assert: one mutation → one notification.
      expect(notifyCount, equals(1));
    });

    testAsync(
        'dispose cancels the subscription — subsequent state manager '
        'mutations stop notifying the delegate listeners', (fa) {
      // arrange
      final stateManager = RouteNodeStateManager(routeNode: makeNode());
      addTearDown(stateManager.close);
      final actualDelegate = YxRouterDelegate(
        stateManager: stateManager,
        routeNodeBuilder: RouteNodeBuilderMock(),
      );
      var notifyCount = 0;
      actualDelegate
        ..addListener(() => notifyCount++)
        // act: dispose first, then mutate state manager.
        ..dispose();
      fa.flushMicrotasks();
      final notifyCountAfterDispose = notifyCount;
      stateManager.mutate(
        (state) => makeNode(route: makeRoute(id: 'after_dispose')),
      );
      fa.flushMicrotasks();

      // assert: after dispose, listeners were NOT further notified by
      // subsequent state manager events — the subscription is cancelled.
      expect(notifyCount, equals(notifyCountAfterDispose));
    });

    test('assigns auto-generated navigator key when none is provided', () {
      // arrange
      final stateManager = RouteNodeStateManager(routeNode: makeNode());
      addTearDown(stateManager.close);
      final actualDelegate = YxRouterDelegate(
        stateManager: stateManager,
        routeNodeBuilder: RouteNodeBuilderMock(),
      );
      addTearDown(actualDelegate.dispose);

      // assert
      expect(actualDelegate.navigatorKey, isA<GlobalKey<NavigatorState>>());
    });

    testWidgets(
        'build renders declared route widget and wraps in a '
        'NavigationConfigProvider', (tester) async {
      // arrange: NavigatorOutlet renders the state manager's root node
      // CHILDREN as pages — so put the homeRoute as a child of a root.
      const homeRoute = YxRoute(id: 'home');
      final stateManager = RouteNodeStateManager(
        routeNode: makeNode(
          route: makeRoute(id: 'root'),
          children: [makeNode(route: homeRoute)],
        ),
      );
      final actualDelegate = YxRouterDelegate(
        stateManager: stateManager,
        routeNodeBuilder: _builderForRoute(homeRoute),
      );
      addTearDown(() async {
        await actualDelegate.dispose();
        await stateManager.close();
      });

      // act: pump delegate output directly (no ancestor config provider).
      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: actualDelegate,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // assert: the Text placed by the declared routeBuilder appears.
      expect(find.text('route:home'), findsOneWidget);
      // And since there was no existing provider in context, the delegate
      // must have wrapped its navigator in a fresh one.
      expect(find.byType(NavigationConfigProvider), findsOneWidget);
    });

    testWidgets(
        'build skips adding its own NavigationConfigProvider when an '
        'ancestor already provides one', (tester) async {
      // arrange
      const homeRoute = YxRoute(id: 'home');
      final stateManager = RouteNodeStateManager(
        routeNode: makeNode(
          route: makeRoute(id: 'root'),
          children: [makeNode(route: homeRoute)],
        ),
      );
      final actualDelegate = YxRouterDelegate(
        stateManager: stateManager,
        routeNodeBuilder: _builderForRoute(homeRoute),
      );
      addTearDown(() async {
        await actualDelegate.dispose();
        await stateManager.close();
      });

      // act: wrap an ancestor NavigationConfigProvider, so the delegate
      // should NOT nest another one.
      await tester.pumpWidget(
        NavigationConfigProvider(
          child: MaterialApp.router(
            routerDelegate: actualDelegate,
            backButtonDispatcher: RootBackButtonDispatcher(),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // assert: still rendered the declared route widget.
      expect(find.text('route:home'), findsOneWidget);
      // There is exactly one NavigationConfigProvider in the tree — the
      // ancestor supplied by the test. If the delegate added its own, we'd
      // see two.
      expect(find.byType(NavigationConfigProvider), findsOneWidget);
    });
  });
}
