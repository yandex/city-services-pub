import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/guard/guard_observer.dart';
import 'package:yx_navigation/src/guard/guard_sync.dart';
import 'package:yx_navigation/src/guard/route_node_guard.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

/// Subclass that records every hook invocation into a list so we can assert
/// the base class actually dispatches to the overridden implementation.
class _RecordingObserver extends GuardObserver {
  final List<String> calls = [];

  @override
  void onStart(RouteNode origin, RouteNode target) {
    super.onStart(origin, target);
    calls.add('onStart:${origin.route.id}->${target.route.id}');
  }

  @override
  void onGuard(
    RouteNode origin,
    RouteNode target,
    RouteNodeGuard guard,
  ) {
    super.onGuard(origin, target, guard);
    calls.add('onGuard');
  }

  @override
  void onNext(
    RouteNode origin,
    RouteNode target,
    RouteNodeGuard? guard,
  ) {
    super.onNext(origin, target, guard);
    calls.add('onNext:${guard == null ? 'null' : 'guard'}');
  }

  @override
  void onCancel(
    RouteNode origin,
    RouteNode target,
    RouteNodeGuard guard,
  ) {
    super.onCancel(origin, target, guard);
    calls.add('onCancel');
  }

  @override
  void onRedirect(
    RouteNode origin,
    RouteNode target,
    RouteNode redirect,
    RouteNodeGuard? guard,
  ) {
    super.onRedirect(origin, target, redirect, guard);
    calls.add('onRedirect:${redirect.route.id}');
  }

  @override
  void onGuardError(
    RouteNode origin,
    RouteNode target,
    Object error,
    StackTrace stackTrace,
    RouteNodeGuard guard,
  ) {
    super.onGuardError(origin, target, error, stackTrace, guard);
    calls.add('onGuardError:$error');
  }

  @override
  void onGuardSync(GuardSyncReason reason) {
    super.onGuardSync(reason);
    calls.add('onGuardSync:${reason.message}');
  }
}

void main() {
  setUpAll(registerFallbacks);

  group('GuardObserver', () {
    test(
      'base class dispatches to subclass overrides without altering arguments',
      () {
        // arrange
        final actualObserver = _RecordingObserver();
        final actualOrigin = makeNode(route: makeRoute(id: 'origin'));
        final actualTarget = makeNode(route: makeRoute(id: 'target'));
        final actualRedirect = makeNode(route: makeRoute(id: 'redirect'));
        final actualGuard = RouteNodeGuardMock();

        // act
        actualObserver
          ..onStart(actualOrigin, actualTarget)
          ..onGuard(actualOrigin, actualTarget, actualGuard)
          ..onNext(actualOrigin, actualTarget, actualGuard)
          ..onNext(actualOrigin, actualTarget, null)
          ..onCancel(actualOrigin, actualTarget, actualGuard)
          ..onRedirect(
            actualOrigin,
            actualTarget,
            actualRedirect,
            actualGuard,
          )
          ..onGuardError(
            actualOrigin,
            actualTarget,
            StateError('boom'),
            StackTrace.empty,
            actualGuard,
          )
          ..onGuardSync(const GuardSyncReason(message: 'boot'));

        // assert: overrides ran in order, with forwarded arguments.
        expect(
          actualObserver.calls,
          orderedEquals(<String>[
            'onStart:origin->target',
            'onGuard',
            'onNext:guard',
            'onNext:null',
            'onCancel',
            'onRedirect:redirect',
            'onGuardError:Bad state: boom',
            'onGuardSync:boot',
          ]),
        );
      },
    );
  });
}
