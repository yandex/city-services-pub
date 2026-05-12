import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
// internal type, not exported
import 'package:yx_navigation_flutter/src/compatibility/compatibility_observer.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

/// Default subclass — every hook inherits the base no-op.
class _NoopObserver extends CompatibilityObserver {}

/// Subclass that records each hook call and overrides [willPushPagelessRoute]
/// to return false.
class _RecordingBlockingObserver extends CompatibilityObserver {
  final List<String> calls = [];

  @override
  bool willPushPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
  }) {
    calls.add('willPush:$routeId');
    return false;
  }

  @override
  void didCreatePagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
    required String routeType,
    required RouteNode routeNode,
  }) {
    calls.add('didCreate:$routeType:$routeId');
  }

  @override
  void didFailPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required Object error,
    required RouteNode? routeNode,
  }) {
    calls.add('didFail:$error');
  }
}

class _FakeNodeReadable implements RouteNodeReadable {
  const _FakeNodeReadable();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(registerFallbacks);

  group('CompatibilityObserver', () {
    test(
      'default implementations: willPush allows (returns true) and lifecycle '
      'hooks are no-ops that return normally',
      () {
        // arrange
        final actualObserver = _NoopObserver();
        final actualRoute = MaterialPageRoute<Object?>(
          builder: (_) => const SizedBox.shrink(),
        );
        final actualNode = makeNode();

        // act & assert
        expect(
          actualObserver.willPushPagelessRoute(
            routeNodeReadable: const _FakeNodeReadable(),
            route: actualRoute,
            routeId: 'id',
          ),
          isTrue,
        );
        expect(
          () {
            actualObserver
              ..didCreatePagelessRoute(
                routeNodeReadable: const _FakeNodeReadable(),
                route: actualRoute,
                routeId: 'id',
                routeType: 'MaterialPageRoute',
                routeNode: actualNode,
              )
              ..didFailPagelessRoute(
                routeNodeReadable: const _FakeNodeReadable(),
                route: actualRoute,
                error: Exception('boom'),
                routeNode: null,
              );
          },
          returnsNormally,
        );
      },
    );

    test(
      'subclass overrides are dispatched with the forwarded arguments',
      () {
        // arrange
        final actualObserver = _RecordingBlockingObserver();
        final actualRoute = MaterialPageRoute<Object?>(
          builder: (_) => const SizedBox.shrink(),
        );
        final actualNode = makeNode();

        // act
        final actualAllow = actualObserver.willPushPagelessRoute(
          routeNodeReadable: const _FakeNodeReadable(),
          route: actualRoute,
          routeId: 'rid',
        );
        actualObserver
          ..didCreatePagelessRoute(
            routeNodeReadable: const _FakeNodeReadable(),
            route: actualRoute,
            routeId: 'rid',
            routeType: 'MaterialPageRoute',
            routeNode: actualNode,
          )
          ..didFailPagelessRoute(
            routeNodeReadable: const _FakeNodeReadable(),
            route: actualRoute,
            error: Exception('boom'),
            routeNode: null,
          );

        // assert
        expect(actualAllow, isFalse);
        expect(
          actualObserver.calls,
          orderedEquals(<String>[
            'willPush:rid',
            'didCreate:MaterialPageRoute:rid',
            'didFail:Exception: boom',
          ]),
        );
      },
    );
  });
}
