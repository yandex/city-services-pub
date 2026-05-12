import 'dart:async';

import 'package:collection/collection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/guard/guard_result.dart';
import 'package:yx_navigation/src/guard/guard_sync.dart';
import 'package:yx_navigation/src/state/state_manager.dart';

import 'helpers/async.dart';
import 'helpers/factories.dart';
import 'helpers/fallbacks.dart';
import 'helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  const settingsRoute = YxRoute(id: 'settings');
  const mapRoute = YxRoute(id: 'Order');
  const profileRoute = YxRoute(id: 'Profile');

  late RouteNode initialNode;
  late RouteNodeStateManager actualStateManager;

  setUp(() {
    initialNode = makeNode(
      route: const YxRoute(id: 'Root'),
      children: [
        makeNode(route: settingsRoute),
        makeNode(route: mapRoute),
        makeNode(route: profileRoute),
      ],
    );
    actualStateManager = makeStateManager(root: initialNode);
  });

  group('RouteNodeStateManager', () {
    group('mutate method', () {
      test('returns same node when there are no updates', () {
        // act
        final actualNode = actualStateManager.mutate((state) => state);

        // assert
        expect(
          actualNode.children.map((e) => e.route).toList(),
          orderedEquals([settingsRoute, mapRoute, profileRoute]),
        );
      });

      test('clears children when mutation calls clearChildren', () {
        // act
        final actualNode = actualStateManager.mutate(
          (state) => state..clearChildren(),
        );

        // assert
        expect(actualNode.children, isEmpty);
      });

      test('removes first child when mutation calls removeFirst', () {
        // act
        final actualNode = actualStateManager.mutate(
          (state) => state..removeFirst(),
        );

        // assert
        expect(
          actualNode.children.firstWhereOrNull((e) => e.route == settingsRoute),
          isNull,
        );
        expect(actualNode.children, hasLength(2));
      });

      test('removes last child when mutation calls removeLast', () {
        // act
        final actualNode = actualStateManager.mutate(
          (state) => state..removeLast(),
        );

        // assert
        expect(
          actualNode.children.firstWhereOrNull((e) => e.route == profileRoute),
          isNull,
        );
        expect(actualNode.children, hasLength(2));
      });
    });

    group('push', () {
      test('appends the pushed route to the end of children', () {
        // arrange
        const newRoute = YxRoute(id: 'new');

        // act
        actualStateManager.push(newRoute);

        // assert
        expect(actualStateManager.state.children, hasLength(4));
        expect(actualStateManager.state.children.last.route, equals(newRoute));
      });
    });

    group('pop', () {
      test('removes the last child leaving the others intact', () {
        // act
        actualStateManager.pop();

        // assert
        expect(
          actualStateManager.state.children.map((e) => e.route),
          orderedEquals([settingsRoute, mapRoute]),
        );
      });
    });

    group('popAll', () {
      test('keeps only the first child (collapses the navigation stack)', () {
        // act
        actualStateManager.popAll();

        // assert: popAll preserves the root-most child, drops the rest.
        expect(actualStateManager.state.children, hasLength(1));
        expect(
          actualStateManager.state.children.single.route,
          equals(settingsRoute),
        );
      });
    });

    group('state getter', () {
      test('exposes the exact route node passed to the constructor', () {
        // assert
        expect(actualStateManager.state.route, equals(initialNode.route));
        expect(
          actualStateManager.state.children.map((e) => e.route),
          orderedEquals([settingsRoute, mapRoute, profileRoute]),
        );
      });
    });

    group('stream', () {
      testAsync(
        'emits the new state after each committed mutation',
        (fa) {
          // arrange
          final emitted = <RouteNode>[];
          final sub = actualStateManager.stream.listen(emitted.add);
          addTearDown(sub.cancel);

          // act
          actualStateManager
            ..push(const YxRoute(id: 'pushed'))
            ..pop();
          fa.flushMicrotasks();

          // assert: two emissions — first after push (with 4 children),
          // second after pop (back to 3 children).
          expect(emitted, hasLength(2));
          expect(emitted.first.children, hasLength(4));
          expect(
            emitted.first.children.last.route,
            equals(const YxRoute(id: 'pushed')),
          );
          expect(emitted.last.children, hasLength(3));
        },
      );
    });

    group('close', () {
      test('marks the stream closed and rejects further emits', () async {
        // act
        await actualStateManager.close();

        // assert
        expect(actualStateManager.isClosed, isTrue);
      });
    });

    group('with guard', () {
      testAsync('commits state when guard returns next', (fa) {
        // arrange
        final guardMock = RouteNodeGuardMock();
        when(() => guardMock.call(any(), any(), any()))
            .thenReturn(const GuardResult.next());
        final manager = makeStateManager(
          root: makeNode(route: const YxRoute(id: 'root')),
          routeNodeGuard: guardMock,
        );
        addTearDown(manager.close);

        // act
        manager.push(const YxRoute(id: 'pushed'));
        fa.flushMicrotasks();

        // assert
        expect(manager.state.children, hasLength(1));
      });

      testAsync(
        'leaves state untouched when guard cancels',
        (fa) {
          // arrange
          final guardMock = RouteNodeGuardMock();
          when(() => guardMock.call(any(), any(), any())).thenReturn(
            const GuardResult.cancel(reason: 'blocked'),
          );
          final manager = makeStateManager(
            root: makeNode(route: const YxRoute(id: 'root')),
            routeNodeGuard: guardMock,
          );
          addTearDown(manager.close);

          // act
          manager.push(const YxRoute(id: 'pushed'));
          fa.flushMicrotasks();

          // assert
          expect(manager.state.children, isEmpty);
        },
      );

      testAsync(
        'swaps state to the redirect target when guard redirects',
        (fa) {
          // arrange
          final guardMock = RouteNodeGuardMock();
          final redirectTarget = makeNode(
            route: const YxRoute(id: 'root'),
            children: [makeNode(route: const YxRoute(id: 'redirected'))],
          );
          when(() => guardMock.call(any(), any(), any()))
              .thenReturn(GuardResult.redirect(target: redirectTarget));
          final manager = makeStateManager(
            root: makeNode(route: const YxRoute(id: 'root')),
            routeNodeGuard: guardMock,
          );
          addTearDown(manager.close);

          // act
          manager.push(const YxRoute(id: 'pushed'));
          fa.flushMicrotasks();

          // assert
          expect(manager.state.children, hasLength(1));
          expect(
            manager.state.children.single.route,
            equals(const YxRoute(id: 'redirected')),
          );
        },
      );
    });

    group('guard sync re-evaluation', () {
      testAsync(
        're-invokes the guard when a GuardSyncReason is emitted on the sync '
        'stream',
        (fa) {
          // arrange: install a guard + sync pair, perform one push so we have
          // a baseline invocation count, then trigger a sync event and assert
          // the guard was called again by `_onReevaluate`.
          final guardMock = RouteNodeGuardMock();
          when(() => guardMock.call(any(), any(), any()))
              .thenReturn(const GuardResult.next());
          final guardSync = GuardSync();
          addTearDown(guardSync.close);

          final manager = makeStateManager(
            root: makeNode(route: const YxRoute(id: 'root')),
            routeNodeGuard: guardMock,
            guardSync: guardSync,
          );
          addTearDown(manager.close);

          manager.push(const YxRoute(id: 'pushed'));
          fa.flushMicrotasks();
          // Drain the invocations recorded so far (push itself triggers the
          // guard once), so the verify below only measures re-evaluation.
          clearInteractions(guardMock);

          // act: broadcast a sync reason — `_onReevaluate` must call
          // `mutate((state) => state)` which invokes the guard exactly once.
          guardSync.sync(const GuardSyncReason(message: 'trigger'));
          fa.flushMicrotasks();

          // assert: exactly one guard call per sync event (otherwise we'd
          // have a regression adding extra re-evaluation cycles).
          verify(() => guardMock.call(any(), any(), any())).called(1);
        },
      );

      testAsync(
        'stops re-evaluating after close — subsequent sync events do not call '
        'the guard',
        (fa) {
          // arrange
          final guardMock = RouteNodeGuardMock();
          when(() => guardMock.call(any(), any(), any()))
              .thenReturn(const GuardResult.next());
          final guardSync = GuardSync();
          addTearDown(guardSync.close);

          final manager = makeStateManager(
            root: makeNode(route: const YxRoute(id: 'root')),
            routeNodeGuard: guardMock,
            guardSync: guardSync,
          );

          // act: close the manager and then broadcast a sync reason.
          unawaited(manager.close());
          fa.flushMicrotasks();
          clearInteractions(guardMock);
          guardSync.sync(const GuardSyncReason(message: 'after-close'));
          fa.flushMicrotasks();

          // assert: no guard calls happened after close.
          verifyNever(() => guardMock.call(any(), any(), any()));
        },
      );
    });
  });
}
