import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/guard/default/redirect_route_node_guard.dart';
import 'package:yx_navigation/src/guard/guard_configuration.dart';
import 'package:yx_navigation/src/guard/guard_context.dart';
import 'package:yx_navigation/src/guard/guard_observer.dart';
import 'package:yx_navigation/src/guard/guard_result.dart';
import 'package:yx_navigation/src/guard/route_node_guard.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  late RouteNode actualOrigin;
  late RouteNode actualTarget;
  late GuardContext actualContext;

  setUp(() {
    actualOrigin = makeNode(route: makeRoute(id: 'origin'));
    actualTarget = makeNode(route: makeRoute(id: 'target'));
    actualContext = GuardContext();
  });

  group('GuardConfiguration', () {
    test(
      'prepends the redirect guard before user guards in the chain',
      () {
        // arrange: two user guards that both return next, plus an observer
        // that lets us assert the redirect guard was invoked first.
        final calls = <String>[];
        const redirectGuard = RedirectRouteNodeGuard();
        final userGuardA = _RecordingNextGuard(calls, 'A');
        final userGuardB = _RecordingNextGuard(calls, 'B');
        final observer = _CallOrderObserver(calls, redirectGuard);
        final RouteNodeGuard configuration = GuardConfiguration(
          redirectGuard: redirectGuard,
          guards: [userGuardA, userGuardB],
          observer: observer,
        );

        // act
        final actualResult = configuration.call(
          actualOrigin,
          actualTarget,
          actualContext,
        );

        // assert: observer saw onGuard for redirect guard before user
        // guards emit their labels.
        expect(actualResult, isA<GuardResultNext>());
        expect(
          calls,
          orderedEquals(<String>['redirect', 'A', 'B']),
        );
      },
    );

    test(
      'dispatches onStart, onGuard, onNext for each guard and trailing onNext '
      'with null guard on successful next-chain',
      () {
        // arrange
        final observerMock = GuardObserverMock();
        final guardMock = RouteNodeGuardMock();
        when(() => guardMock.call(any(), any(), any()))
            .thenReturn(const GuardResult.next());
        final RouteNodeGuard configuration = GuardConfiguration(
          guards: [guardMock],
          observer: observerMock,
        );

        // act
        final actualResult = configuration.call(
          actualOrigin,
          actualTarget,
          actualContext,
        );

        // assert
        expect(actualResult, isA<GuardResultNext>());
        verify(() => observerMock.onStart(any(), any())).called(1);
        verify(() => observerMock.onGuard(any(), any(), guardMock)).called(1);
        verify(() => observerMock.onNext(any(), any(), guardMock)).called(1);
        verify(() => observerMock.onNext(any(), any(), null)).called(1);
        verifyNever(() => observerMock.onCancel(any(), any(), any()));
        verifyNever(() => observerMock.onRedirect(any(), any(), any(), any()));
      },
    );

    test('dispatches onCancel observer hook when guard returns cancel', () {
      // arrange
      final observerMock = GuardObserverMock();
      final guardMock = RouteNodeGuardMock();
      when(() => guardMock.call(any(), any(), any()))
          .thenReturn(const GuardResult.cancel(reason: 'no'));
      final RouteNodeGuard configuration = GuardConfiguration(
        guards: [guardMock],
        observer: observerMock,
      );

      // act
      final actualResult = configuration.call(
        actualOrigin,
        actualTarget,
        actualContext,
      );

      // assert
      expect(actualResult, isA<GuardResultCancel>());
      verify(() => observerMock.onStart(any(), any())).called(1);
      verify(() => observerMock.onGuard(any(), any(), guardMock)).called(1);
      verify(() => observerMock.onCancel(any(), any(), guardMock)).called(1);
      verifyNever(() => observerMock.onNext(any(), any(), any()));
      verifyNever(() => observerMock.onRedirect(any(), any(), any(), any()));
    });

    test(
      'dispatches onRedirect observer hook and returns redirect result when '
      'loop completes with a redirect target',
      () {
        // arrange: first guard emits a redirect; when the second pass runs,
        // the guard emits next so the loop completes with a pending redirect.
        final observerMock = GuardObserverMock();
        final redirectNode = makeNode(route: makeRoute(id: 'redirected'));
        final guard = _RedirectThenNextGuard(redirectNode);
        final RouteNodeGuard configuration = GuardConfiguration(
          guards: [guard],
          observer: observerMock,
        );

        // act
        final actualResult = configuration.call(
          actualOrigin,
          actualTarget,
          actualContext,
        );

        // assert: final result is a redirect targeting the redirect node.
        expect(actualResult, isA<GuardResultRedirect>());
        expect(
          (actualResult as GuardResultRedirect).target.route,
          equals(redirectNode.route),
        );
        verify(() => observerMock.onRedirect(any(), any(), any(), guard))
            .called(1);
      },
    );

    test(
      'converts any throw from a guard into GuardResult.cancel with the error '
      'as reason and dispatches onGuardError',
      () {
        // arrange
        final observerMock = GuardObserverMock();
        final guardMock = RouteNodeGuardMock();
        final expectedError = StateError('boom');
        when(() => guardMock.call(any(), any(), any()))
            .thenThrow(expectedError);
        final RouteNodeGuard configuration = GuardConfiguration(
          guards: [guardMock],
          observer: observerMock,
        );

        // act
        final actualResult = configuration.call(
          actualOrigin,
          actualTarget,
          actualContext,
        );

        // assert
        expect(actualResult, isA<GuardResultCancel>());
        expect(
          (actualResult as GuardResultCancel).reason,
          same(expectedError),
        );
        verify(
          () => observerMock.onGuardError(
            any(),
            any(),
            expectedError,
            any(),
            guardMock,
          ),
        ).called(1);
        verifyNever(() => observerMock.onCancel(any(), any(), any()));
      },
    );

    test(
      'final onNext is called with null guard when loop completes without '
      'redirect',
      () {
        // arrange
        final observerMock = GuardObserverMock();
        final guardMock = RouteNodeGuardMock();
        when(() => guardMock.call(any(), any(), any()))
            .thenReturn(const GuardResult.next());

        // act
        (GuardConfiguration(guards: [guardMock], observer: observerMock)
                as RouteNodeGuard)
            .call(actualOrigin, actualTarget, actualContext);

        // assert: tail `onNext(..., null)` is the loop-completion hook.
        verify(() => observerMock.onNext(any(), any(), null)).called(1);
      },
    );

    test('call with no guards still fires onStart and trailing onNext(null)',
        () {
      // arrange
      final observerMock = GuardObserverMock();
      final RouteNodeGuard configuration =
          GuardConfiguration(observer: observerMock);

      // act
      final actualResult = configuration.call(
        actualOrigin,
        actualTarget,
        actualContext,
      );

      // assert
      expect(actualResult, isA<GuardResultNext>());
      verify(() => observerMock.onStart(any(), any())).called(1);
      verify(() => observerMock.onNext(any(), any(), null)).called(1);
      verifyNever(() => observerMock.onGuard(any(), any(), any()));
    });
  });
}

/// A guard that records its invocation and returns next.
class _RecordingNextGuard implements RouteNodeGuard {
  final List<String> calls;
  final String label;

  _RecordingNextGuard(this.calls, this.label);

  @override
  GuardResult call(
    RouteNode origin,
    RouteNode target,
    Map<String, Object> context,
  ) {
    calls.add(label);
    return const GuardResult.next();
  }
}

/// A guard that emits a redirect the first time and next on subsequent calls.
/// Lets us drive `GuardConfiguration` into the `redirect != null` branch of
/// `_processGuards` so the loop completes with a pending redirect.
class _RedirectThenNextGuard implements RouteNodeGuard {
  final RouteNode redirect;
  int _calls = 0;

  _RedirectThenNextGuard(this.redirect);

  @override
  GuardResult call(
    RouteNode origin,
    RouteNode target,
    Map<String, Object> context,
  ) {
    _calls++;
    if (_calls == 1) {
      return GuardResult.redirect(target: redirect);
    }
    return const GuardResult.next();
  }
}

/// Observer that records `onGuard` in the same list the test's
/// `_RecordingNextGuard` writes into, so we can assert global call order.
class _CallOrderObserver extends GuardObserver {
  final List<String> calls;
  final RouteNodeGuard redirectGuard;

  _CallOrderObserver(this.calls, this.redirectGuard);

  @override
  void onGuard(RouteNode origin, RouteNode target, RouteNodeGuard guard) {
    super.onGuard(origin, target, guard);
    if (identical(guard, redirectGuard)) {
      calls.add('redirect');
    }
  }
}
