import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/guard/default/redirect_route_node_guard.dart';
import 'package:yx_navigation/src/guard/guard_configuration.dart';
import 'package:yx_navigation/src/guard/guard_context.dart';
import 'package:yx_navigation/src/guard/guard_result.dart';
import 'package:yx_navigation/src/guard/route_node_guard.dart';

/// Fake user-guard that emits a redirect a fixed number of times before
/// falling through to `next`. Records total invocations so tests can assert
/// the composition (how many loops `GuardConfiguration` ran).
class FakeRouteNodeGuard implements RouteNodeGuard {
  int redirectCount = 0;
  int invocationCount = 0;

  FakeRouteNodeGuard();

  @override
  GuardResult call(
    RouteNode origin,
    RouteNode target,
    GuardContext context,
  ) {
    invocationCount++;
    if (redirectCount == 0) {
      return const GuardResult.next();
    }

    redirectCount--;
    return GuardResult.redirect(
      target: target.copyWith(arguments: {'redirected': '$redirectCount'}),
    );
  }

  @visibleForTesting
  // ignore: use_setters_to_change_properties
  void setRedirectCount(int count) {
    redirectCount = count;
  }
}

void main() {
  const maxRedirects = 3;
  late FakeRouteNodeGuard fakeRouteNodeGuard;
  late RedirectRouteNodeGuard redirectRouteNodeGuard;
  late RouteNodeGuard actualGuardConfiguration;

  late RouteNode origin;
  late RouteNode target;
  late GuardContext context;

  setUp(() {
    fakeRouteNodeGuard = FakeRouteNodeGuard();
    redirectRouteNodeGuard = const RedirectRouteNodeGuard(
      maxRedirects: maxRedirects,
    );
    actualGuardConfiguration = GuardConfiguration(
      redirectGuard: redirectRouteNodeGuard,
      guards: [fakeRouteNodeGuard],
    );

    origin = RouteNode.fromRoute(route: const YxRoute(id: 'origin'));
    target = RouteNode.fromRoute(route: const YxRoute(id: 'target'));
    context = GuardContext();
  });

  group('GuardConfiguration with RedirectRouteNodeGuard', () {
    test(
      'returns GuardResultNext when no redirects are requested and user '
      'guard is invoked exactly once',
      () {
        // arrange
        fakeRouteNodeGuard.setRedirectCount(0);

        // act
        final actual = actualGuardConfiguration.call(origin, target, context);

        // assert: straight-through path — GuardResultNext and a single user
        // guard call (no redirect loop).
        expect(actual, isA<GuardResultNext>());
        expect(fakeRouteNodeGuard.invocationCount, equals(1));
      },
    );

    test(
      'returns GuardResultRedirect with the fake guard target when a redirect '
      'is requested below the max',
      () {
        // arrange: fake guard emits `maxRedirects - 1` redirects.
        fakeRouteNodeGuard.setRedirectCount(maxRedirects - 1);

        // act
        final actual = actualGuardConfiguration.call(origin, target, context);

        // assert: the configuration returns a redirect carrying the target
        // the fake guard produced. The fake stamps the post-decrement
        // `redirectCount` into `arguments['redirected']`, so with a seed of
        // `maxRedirects - 1` the last redirect target carries '0'.
        expect(actual, isA<GuardResultRedirect>());
        final redirectTarget = (actual as GuardResultRedirect).target;
        expect(redirectTarget.arguments['redirected'], equals('0'));
        // Exact invocation count: fake guard runs once per redirect-loop
        // iteration; total = seed call + redirect iterations = maxRedirects.
        expect(fakeRouteNodeGuard.invocationCount, equals(maxRedirects));
      },
    );

    test('returns GuardResultRedirect when redirect count equals max', () {
      // arrange
      fakeRouteNodeGuard.setRedirectCount(maxRedirects);

      // act
      final actual = actualGuardConfiguration.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultRedirect>());
    });

    test(
      'returns GuardResultCancel explaining a max-redirects breach when the '
      'redirect count exceeds max',
      () {
        // arrange
        fakeRouteNodeGuard.setRedirectCount(maxRedirects + 1);

        // act
        final actual = actualGuardConfiguration.call(origin, target, context);

        // assert: the cancel mentions the "max redirects" concept (match
        // case-insensitive, substring only — the exact wording is not part
        // of the public contract).
        expect(actual, isA<GuardResultCancel>());
        actual as GuardResultCancel;
        expect(
          actual.reason?.toString().toLowerCase(),
          contains('max redirects'),
        );
      },
    );
  });
}
