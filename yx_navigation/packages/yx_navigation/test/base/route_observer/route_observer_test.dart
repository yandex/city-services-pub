import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/base/route_observer/route_node_diff_result.dart';
import 'package:yx_navigation/src/base/route_observer/route_observer.dart';
import 'package:yx_navigation/src/state/base/mutation.dart';

import '../../helpers/factories.dart';
import '../../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('YxRouteObserver', () {
    test(
      'onRouteDiffMutation is a no-op on the base observer (callbacks are '
      'never invoked without an adapter)',
      () {
        // arrange: record invocations — the base observer must NOT dispatch
        // to these callbacks itself; only `RouteObserverAdapter` does.
        var actualPushCalls = 0;
        var actualPopCalls = 0;
        var actualUpdateCalls = 0;
        final actualObserver = YxRouteObserver(
          onPush: (_, __) => actualPushCalls++,
          onPop: (_, __) => actualPopCalls++,
          onUpdate: (_, __) => actualUpdateCalls++,
        );
        final actualRoute = makeRoute(id: 'added');
        final actualMutation = Mutation(
          originalState: makeNode(route: makeRoute(id: 'root')),
          targetState: makeNode(
            route: makeRoute(id: 'root'),
            children: [makeNode(route: actualRoute)],
          ),
        );
        final actualDiff = RouteNodeDiffResult(
          {actualRoute: makeNode(route: actualRoute)},
          const {},
          const {},
        );

        // act
        actualObserver.onRouteDiffMutation(actualMutation, actualDiff);

        // assert
        expect(actualPushCalls, isZero);
        expect(actualPopCalls, isZero);
        expect(actualUpdateCalls, isZero);
      },
    );
  });

  group('RouteObserverAdapter', () {
    test('skips propagation when the diff is empty', () {
      // arrange
      var actualPushCalls = 0;
      var actualPopCalls = 0;
      var actualUpdateCalls = 0;
      final sourceObserver = YxRouteObserver(
        onPush: (_, __) => actualPushCalls++,
        onPop: (_, __) => actualPopCalls++,
        onUpdate: (_, __) => actualUpdateCalls++,
      );
      final actualAdapter =
          RouteObserverAdapter(makeRoute(id: 'target'), sourceObserver);
      final actualMutation = Mutation(
        originalState: makeNode(route: makeRoute(id: 'root')),
        targetState: makeNode(route: makeRoute(id: 'root')),
      );
      const actualDiff = RouteNodeDiffResult({}, {}, {});

      // act
      actualAdapter.onRouteDiffMutation(actualMutation, actualDiff);

      // assert
      expect(actualPushCalls, isZero);
      expect(actualPopCalls, isZero);
      expect(actualUpdateCalls, isZero);
    });

    test('invokes onPush on the source observer when the route is added', () {
      // arrange
      RouteNode? actualOrigin;
      RouteNode? actualTarget;
      final sourceObserver = YxRouteObserver(
        onPush: (origin, target) {
          actualOrigin = origin;
          actualTarget = target;
        },
      );
      final actualRoute = makeRoute(id: 'added');
      final actualAdapter = RouteObserverAdapter(actualRoute, sourceObserver);
      final expectedOrigin = makeNode(route: makeRoute(id: 'root'));
      final expectedTarget = makeNode(
        route: makeRoute(id: 'root'),
        children: [makeNode(route: actualRoute)],
      );
      final actualMutation =
          Mutation(originalState: expectedOrigin, targetState: expectedTarget);
      final actualDiff = RouteNodeDiffResult(
        {actualRoute: makeNode(route: actualRoute)},
        const {},
        const {},
      );

      // act
      actualAdapter.onRouteDiffMutation(actualMutation, actualDiff);

      // assert
      expect(actualOrigin, equals(expectedOrigin));
      expect(actualTarget, equals(expectedTarget));
    });

    test('invokes onPop on the source observer when the route is removed', () {
      // arrange
      RouteNode? actualOrigin;
      RouteNode? actualTarget;
      final sourceObserver = YxRouteObserver(
        onPop: (origin, target) {
          actualOrigin = origin;
          actualTarget = target;
        },
      );
      final actualRoute = makeRoute(id: 'removed');
      final actualAdapter = RouteObserverAdapter(actualRoute, sourceObserver);
      final expectedOrigin = makeNode(
        route: makeRoute(id: 'root'),
        children: [makeNode(route: actualRoute)],
      );
      final expectedTarget = makeNode(route: makeRoute(id: 'root'));
      final actualMutation =
          Mutation(originalState: expectedOrigin, targetState: expectedTarget);
      final actualDiff = RouteNodeDiffResult(
        const {},
        {actualRoute: makeNode(route: actualRoute)},
        const {},
      );

      // act
      actualAdapter.onRouteDiffMutation(actualMutation, actualDiff);

      // assert
      expect(actualOrigin, equals(expectedOrigin));
      expect(actualTarget, equals(expectedTarget));
    });

    test('invokes onUpdate on the source observer when the route is updated',
        () {
      // arrange
      RouteNode? actualOrigin;
      RouteNode? actualTarget;
      final sourceObserver = YxRouteObserver(
        onUpdate: (origin, target) {
          actualOrigin = origin;
          actualTarget = target;
        },
      );
      final actualRoute = makeRoute(id: 'updated');
      final actualAdapter = RouteObserverAdapter(actualRoute, sourceObserver);
      final expectedOrigin = makeNode(
        route: actualRoute,
        arguments: const {'v': '1'},
      );
      final expectedTarget = makeNode(
        route: actualRoute,
        arguments: const {'v': '2'},
      );
      final actualMutation =
          Mutation(originalState: expectedOrigin, targetState: expectedTarget);
      final actualDiff = RouteNodeDiffResult(
        const {},
        const {},
        {
          actualRoute: Mutation(
            originalState: expectedOrigin,
            targetState: expectedTarget,
          ),
        },
      );

      // act
      actualAdapter.onRouteDiffMutation(actualMutation, actualDiff);

      // assert
      expect(actualOrigin, equals(expectedOrigin));
      expect(actualTarget, equals(expectedTarget));
    });

    test('does nothing when the source observer is null', () {
      // arrange
      final actualRoute = makeRoute(id: 'added');
      final actualAdapter = RouteObserverAdapter(actualRoute, null);
      final actualMutation = Mutation(
        originalState: makeNode(route: makeRoute(id: 'root')),
        targetState: makeNode(
          route: makeRoute(id: 'root'),
          children: [makeNode(route: actualRoute)],
        ),
      );
      final actualDiff = RouteNodeDiffResult(
        {actualRoute: makeNode(route: actualRoute)},
        const {},
        const {},
      );

      // act & assert
      expect(
        () => actualAdapter.onRouteDiffMutation(actualMutation, actualDiff),
        returnsNormally,
      );
    });

    test('ignores mutations unrelated to the adapter route', () {
      // arrange
      var actualCalls = 0;
      final sourceObserver = YxRouteObserver(
        onPush: (_, __) => actualCalls++,
        onPop: (_, __) => actualCalls++,
        onUpdate: (_, __) => actualCalls++,
      );
      final actualRoute = makeRoute(id: 'target');
      final unrelatedRoute = makeRoute(id: 'other');
      final actualAdapter = RouteObserverAdapter(actualRoute, sourceObserver);
      final actualMutation = Mutation(
        originalState: makeNode(route: makeRoute(id: 'root')),
        targetState: makeNode(
          route: makeRoute(id: 'root'),
          children: [makeNode(route: unrelatedRoute)],
        ),
      );
      final actualDiff = RouteNodeDiffResult(
        {unrelatedRoute: makeNode(route: unrelatedRoute)},
        const {},
        const {},
      );

      // act
      actualAdapter.onRouteDiffMutation(actualMutation, actualDiff);

      // assert
      expect(actualCalls, isZero);
    });
  });
}
