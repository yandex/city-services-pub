import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route_observer/route_node_diff_result.dart';
import 'package:yx_navigation/src/state/base/mutation.dart';

import '../../helpers/factories.dart';
import '../../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('RouteNodeDiffResult', () {
    test('equality holds across two identically constructed instances', () {
      // arrange
      final actualRoute = makeRoute(id: 'x');
      final actualNode = makeNode(route: actualRoute);
      final actualMutation = Mutation(
        originalState: actualNode,
        targetState: actualNode,
      );
      final actualFirst = RouteNodeDiffResult(
        {actualRoute: actualNode},
        const {},
        {actualRoute: actualMutation},
      );
      final actualSecond = RouteNodeDiffResult(
        {actualRoute: actualNode},
        const {},
        {actualRoute: actualMutation},
      );

      // assert: two instances built from the same inputs expose the same
      // added/removed/updates maps.
      expect(actualFirst.added, equals(actualSecond.added));
      expect(actualFirst.removed, equals(actualSecond.removed));
      expect(actualFirst.updates, equals(actualSecond.updates));
    });

    test('isEmpty returns true when no changes are present', () {
      // arrange
      const actualResult = RouteNodeDiffResult({}, {}, {});

      // assert
      expect(actualResult.isEmpty, isTrue);
      expect(actualResult.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true when added map is populated', () {
      // arrange
      final actualRoute = makeRoute(id: 'x');
      final actualResult = RouteNodeDiffResult(
        {actualRoute: makeNode(route: actualRoute)},
        const {},
        const {},
      );

      // assert
      expect(actualResult.isEmpty, isFalse);
      expect(actualResult.isNotEmpty, isTrue);
    });

    test('isNotEmpty returns true when updates map is populated', () {
      // arrange
      final actualRoute = makeRoute(id: 'x');
      final actualNode = makeNode(route: actualRoute);
      final actualResult = RouteNodeDiffResult(
        const {},
        const {},
        {
          actualRoute:
              Mutation(originalState: actualNode, targetState: actualNode),
        },
      );

      // assert
      expect(actualResult.isNotEmpty, isTrue);
    });

    group('difference factory', () {
      test('returns empty diff when two nodes are identical', () {
        // arrange
        final actualNode = makeNode(
          route: makeRoute(id: 'root'),
          children: [makeNode(route: makeRoute(id: 'a'))],
        );

        // act
        final actualResult =
            RouteNodeDiffResult.difference(actualNode, actualNode);

        // assert
        expect(actualResult.isEmpty, isTrue);
      });

      test('reports the added route when the target gains a child', () {
        // arrange
        final rootRoute = makeRoute(id: 'root');
        final addedRoute = makeRoute(id: 'added');
        final actualOrigin = makeNode(route: rootRoute);
        final actualTarget = makeNode(
          route: rootRoute,
          children: [makeNode(route: addedRoute)],
        );

        // act
        final actualResult =
            RouteNodeDiffResult.difference(actualOrigin, actualTarget);

        // assert
        expect(actualResult.added.keys, contains(addedRoute));
        expect(actualResult.removed, isEmpty);
      });

      test('reports the removed route when the target drops a child', () {
        // arrange
        final rootRoute = makeRoute(id: 'root');
        final removedRoute = makeRoute(id: 'removed');
        final actualOrigin = makeNode(
          route: rootRoute,
          children: [makeNode(route: removedRoute)],
        );
        final actualTarget = makeNode(route: rootRoute);

        // act
        final actualResult =
            RouteNodeDiffResult.difference(actualOrigin, actualTarget);

        // assert
        expect(actualResult.removed.keys, contains(removedRoute));
        expect(actualResult.added, isEmpty);
      });
    });
  });
}
