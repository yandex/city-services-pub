import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/base/route_observer/route_observer.dart';
import 'package:yx_navigation/src/base/route_observer/state_manager_diff_observer.dart';
import 'package:yx_navigation/src/state/base/mutation.dart';

import '../../helpers/factories.dart';
import '../../helpers/fallbacks.dart';
import '../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('StateManagerDiffObserver', () {
    test('onCreate delegates to the source observer', () {
      // arrange/act
      final actualSource = StateManagerObserverMock();
      final actualStateManager = makeStateManager();
      StateManagerDiffObserver(
        sourceObserver: actualSource,
        routeObservers: const [],
      ).onCreate(actualStateManager);

      // assert
      verify(() => actualSource.onCreate(actualStateManager)).called(1);
    });

    test('onClose delegates to the source observer', () {
      // arrange/act
      final actualSource = StateManagerObserverMock();
      final actualStateManager = makeStateManager();
      StateManagerDiffObserver(
        sourceObserver: actualSource,
        routeObservers: const [],
      ).onClose(actualStateManager);

      // assert
      verify(() => actualSource.onClose(actualStateManager)).called(1);
    });

    test('onError delegates to the source observer with error and stack', () {
      // arrange
      final actualSource = StateManagerObserverMock();
      final actualStateManager = makeStateManager();
      final actualObserver = StateManagerDiffObserver(
        sourceObserver: actualSource,
        routeObservers: const [],
      );
      final actualError = StateError('boom');
      final actualStack = StackTrace.current;

      // act
      actualObserver.onError(actualStateManager, actualError, actualStack);

      // assert
      verify(
        () =>
            actualSource.onError(actualStateManager, actualError, actualStack),
      ).called(1);
    });

    test('onMutation delegates to the source observer', () {
      // arrange
      final actualSource = StateManagerObserverMock();
      final actualStateManager = makeStateManager();
      final actualObserver = StateManagerDiffObserver(
        sourceObserver: actualSource,
        routeObservers: const [],
      );
      final actualMutation = Mutation(
        originalState: makeNode(route: makeRoute(id: 'root')),
        targetState: makeNode(route: makeRoute(id: 'root')),
      );

      // act
      actualObserver.onMutation(actualStateManager, actualMutation);

      // assert
      verify(
        () => actualSource.onMutation(actualStateManager, actualMutation),
      ).called(1);
    });

    test('notifies route observers about the computed diff on mutation', () {
      // arrange
      final actualRoute = makeRoute(id: 'added');
      final actualStateManager = makeStateManager();
      var actualCalls = 0;
      RouteNode? actualPushOrigin;
      RouteNode? actualPushTarget;
      final actualRouteObserver = RouteObserverAdapter(
        actualRoute,
        YxRouteObserver(
          onPush: (origin, target) {
            actualCalls++;
            actualPushOrigin = origin;
            actualPushTarget = target;
          },
        ),
      );
      final actualObserver = StateManagerDiffObserver(
        sourceObserver: null,
        routeObservers: [actualRouteObserver],
      );
      final actualOrigin = makeNode(route: makeRoute(id: 'root'));
      final actualTarget = makeNode(
        route: makeRoute(id: 'root'),
        children: [makeNode(route: actualRoute)],
      );
      final actualMutation =
          Mutation(originalState: actualOrigin, targetState: actualTarget);

      // act
      actualObserver.onMutation(actualStateManager, actualMutation);

      // assert
      expect(actualCalls, equals(1));
      expect(actualPushOrigin, equals(actualOrigin));
      expect(actualPushTarget, equals(actualTarget));
    });

    test(
      'notifies onPop when the observed route is removed from the tree',
      () {
        // arrange
        final actualRoute = makeRoute(id: 'removed');
        final actualStateManager = makeStateManager();
        var actualCalls = 0;
        RouteNode? actualPopOrigin;
        RouteNode? actualPopTarget;
        final actualRouteObserver = RouteObserverAdapter(
          actualRoute,
          YxRouteObserver(
            onPop: (origin, target) {
              actualCalls++;
              actualPopOrigin = origin;
              actualPopTarget = target;
            },
          ),
        );
        final actualObserver = StateManagerDiffObserver(
          sourceObserver: null,
          routeObservers: [actualRouteObserver],
        );
        final actualOrigin = makeNode(
          route: makeRoute(id: 'root'),
          children: [makeNode(route: actualRoute)],
        );
        final actualTarget = makeNode(route: makeRoute(id: 'root'));
        final actualMutation =
            Mutation(originalState: actualOrigin, targetState: actualTarget);

        // act
        actualObserver.onMutation(actualStateManager, actualMutation);

        // assert
        expect(actualCalls, equals(1));
        expect(actualPopOrigin, equals(actualOrigin));
        expect(actualPopTarget, equals(actualTarget));
      },
    );

    test(
      'notifies onUpdate when the observed route has its siblings reshuffled',
      () {
        // arrange: the observed route stays, but its sibling identity
        // changes — this forces the observed node to appear in `updates`.
        final actualRoute = makeRoute(id: 'stable');
        final actualStateManager = makeStateManager();
        var pushCalls = 0;
        var popCalls = 0;
        var updateCalls = 0;
        RouteNode? actualUpdateOrigin;
        RouteNode? actualUpdateTarget;
        final actualRouteObserver = RouteObserverAdapter(
          actualRoute,
          YxRouteObserver(
            onPush: (_, __) => pushCalls++,
            onPop: (_, __) => popCalls++,
            onUpdate: (origin, target) {
              updateCalls++;
              actualUpdateOrigin = origin;
              actualUpdateTarget = target;
            },
          ),
        );
        final actualObserver = StateManagerDiffObserver(
          sourceObserver: null,
          routeObservers: [actualRouteObserver],
        );

        // Note: the diff computes `updates` on the intersection of routes
        // in both trees. We keep the observed route, but give it a different
        // child, which makes the nodes unequal → goes to updates.
        final actualOrigin = makeNode(
          route: makeRoute(id: 'root'),
          children: [
            makeNode(
              route: actualRoute,
              children: [makeNode(route: makeRoute(id: 'child-a'))],
            ),
          ],
        );
        final actualTarget = makeNode(
          route: makeRoute(id: 'root'),
          children: [
            makeNode(
              route: actualRoute,
              children: [makeNode(route: makeRoute(id: 'child-b'))],
            ),
          ],
        );
        final actualMutation =
            Mutation(originalState: actualOrigin, targetState: actualTarget);

        // act
        actualObserver.onMutation(actualStateManager, actualMutation);

        // assert: only onUpdate ran; onPush/onPop stayed at 0.
        expect(pushCalls, equals(0));
        expect(popCalls, equals(0));
        expect(updateCalls, equals(1));
        expect(actualUpdateOrigin, equals(actualOrigin));
        expect(actualUpdateTarget, equals(actualTarget));
      },
    );

    test('skips route observer notification when diff is empty', () {
      // arrange
      final actualRoute = makeRoute(id: 'stable');
      final actualStateManager = makeStateManager();
      var actualCalls = 0;
      final actualRouteObserver = RouteObserverAdapter(
        actualRoute,
        YxRouteObserver(
          onPush: (_, __) => actualCalls++,
          onPop: (_, __) => actualCalls++,
          onUpdate: (_, __) => actualCalls++,
        ),
      );
      final actualObserver = StateManagerDiffObserver(
        sourceObserver: null,
        routeObservers: [actualRouteObserver],
      );
      final actualNode = makeNode(
        route: makeRoute(id: 'root'),
        children: [makeNode(route: actualRoute)],
      );
      final actualMutation =
          Mutation(originalState: actualNode, targetState: actualNode);

      // act
      actualObserver.onMutation(actualStateManager, actualMutation);

      // assert
      expect(actualCalls, equals(0));
    });
  });
}
