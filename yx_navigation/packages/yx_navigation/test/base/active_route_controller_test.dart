import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';

import '../helpers/async.dart';
import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('ActiveRouteController', () {
    const rootRoute = YxRoute(id: 'root');
    const tabARoute = YxRoute(id: 'tabA');
    const tabBRoute = YxRoute(id: 'tabB');

    test('activeRoute returns the last child route of the state', () {
      // arrange
      final actualManager = makeStateManager(
        root: makeNode(
          route: rootRoute,
          children: [makeNode(route: tabARoute), makeNode(route: tabBRoute)],
        ),
      );

      // assert
      expect(actualManager.activeRoute, equals(tabBRoute));
    });

    test('activeRoute returns null when state has no children', () {
      // arrange
      final actualManager = makeStateManager(root: makeNode(route: rootRoute));

      // assert
      expect(actualManager.activeRoute, isNull);
    });

    test('isRouteActive returns true when the given route is active', () {
      // arrange
      final actualManager = makeStateManager(
        root: makeNode(
          route: rootRoute,
          children: [makeNode(route: tabARoute), makeNode(route: tabBRoute)],
        ),
      );

      // assert
      expect(actualManager.isRouteActive(tabBRoute), isTrue);
      expect(actualManager.isRouteActive(tabARoute), isFalse);
    });

    test('setActiveRoute moves the matching child to the end', () {
      // arrange/act
      final actualManager = makeStateManager(
        root: makeNode(
          route: rootRoute,
          children: [makeNode(route: tabARoute), makeNode(route: tabBRoute)],
        ),
      )..setActiveRoute(tabARoute);

      // assert
      expect(actualManager.activeRoute, equals(tabARoute));
      expect(
        actualManager.state.children.map((c) => c.route).toList(),
        orderedEquals(<YxRoute>[tabBRoute, tabARoute]),
      );
    });

    test('setActiveRoute throws StateError when children are empty', () {
      // arrange
      final actualManager = makeStateManager(root: makeNode(route: rootRoute));

      // act & assert
      expect(
        () => actualManager.setActiveRoute(tabARoute),
        throwsStateError,
      );
    });

    test('setActiveRoute throws StateError when route is not a child', () {
      // arrange
      final actualManager = makeStateManager(
        root: makeNode(
          route: rootRoute,
          children: [makeNode(route: tabARoute)],
        ),
      );

      // act & assert
      expect(
        () => actualManager.setActiveRoute(tabBRoute),
        throwsStateError,
      );
    });

    testAsync('activeRouteStream emits distinct active routes on change', (fa) {
      // arrange
      final actualManager = makeStateManager(
        root: makeNode(
          route: rootRoute,
          children: [makeNode(route: tabARoute), makeNode(route: tabBRoute)],
        ),
      );
      final emitted = <YxRoute?>[];
      final sub = actualManager.activeRouteStream.listen(emitted.add);
      addTearDown(sub.cancel);

      // act
      actualManager.setActiveRoute(tabARoute);
      fa.flushMicrotasks();

      // assert
      expect(emitted, equals(<YxRoute?>[tabARoute]));
    });
  });
}
