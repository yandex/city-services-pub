import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_navigator.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/base/route_node_resolver.dart';
import 'package:yx_navigation/src/extensions/route_node_extensions.dart';
import 'package:yx_navigation/src/guard/guard_result.dart';
import 'package:yx_navigation/src/guard/guard_sync.dart';
import 'package:yx_navigation/src/late_initialization/late_init_guard_configuration.dart';
import 'package:yx_navigation/src/state/state_manager.dart';

import '../helpers/async.dart';
import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

void main() {
  late YxRoute home;
  late YxRoute profile;
  late RouteNode routeNode;
  late RouteNodeStateManager stateManager;
  late RouteNodeResolver routeNodeResolver;
  late NavigationController profileNavigationController;
  late LateInitGuardConfiguration lateInitGuardConfiguration;
  late GuardSync guardSync;
  late RouteNodeGuardMock guardMock;

  setUpAll(registerFallbacks);

  setUp(() {
    home = const YxRoute(id: 'home');
    profile = const YxRoute(id: 'profile');
    routeNode = home.toNode();
    lateInitGuardConfiguration = LateInitGuardConfiguration();
    guardMock = RouteNodeGuardMock();
    when(() => guardMock.call(any(), any(), any())).thenReturn(
      const GuardResult.cancel(reason: 'Target route node must has root'),
    );
    lateInitGuardConfiguration.attach('test', [guardMock]);
    guardSync = GuardSync();

    stateManager = RouteNodeStateManager(
      routeNode: routeNode,
      guardSync: guardSync,
      routeNodeGuard: lateInitGuardConfiguration,
    );

    routeNodeResolver = RouteNodeResolver.id(route: profile);
    profileNavigationController = NavigationController.node(
      stateManager: stateManager,
      nodeResolver: routeNodeResolver,
    );
  });

  tearDown(() async {
    await profileNavigationController.close();
    await stateManager.close();
    await guardSync.close();
  });

  group('LateInitGuardConfiguration', () {
    testAsync('cancels push when attached guard returns cancel', (fa) {
      // assert: initial state is empty.
      expect(profileNavigationController.state, isNull);
      expect(stateManager.state.children, isEmpty);

      // act
      stateManager.push(profile);
      fa.flushMicrotasks();

      // assert: push is blocked.
      expect(stateManager.state.children, isEmpty);
    });

    testAsync(
        'allows push when attached guard returns next — mutation goes through',
        (fa) {
      // arrange: swap the default cancelling guard for one that lets through.
      lateInitGuardConfiguration.detach('test');
      final allowingGuard = RouteNodeGuardMock();
      when(() => allowingGuard.call(any(), any(), any()))
          .thenReturn(const GuardResult.next());
      lateInitGuardConfiguration.attach('allow', [allowingGuard]);

      // act
      stateManager.push(profile);
      fa.flushMicrotasks();

      // assert: profile is now a child of the root node.
      expect(stateManager.state.children, hasLength(1));
      expect(stateManager.state.children.single.route, equals(profile));

      // cleanup — this fixture does the detach/cleanup itself so other
      // tests continue from `setUp` state.
      lateInitGuardConfiguration.detach('allow');
    });

    testAsync('redirect result swaps the target state to the redirected node',
        (fa) {
      // arrange
      lateInitGuardConfiguration.detach('test');
      final redirectTarget = RouteNode.fromRoute(
        route: home,
        children: [RouteNode.fromRoute(route: const YxRoute(id: 'redir'))],
      );
      // Redirect exactly once to avoid infinite recursion inside
      // GuardConfiguration._processGuards.
      final redirectingGuard = RouteNodeGuardMock();
      var redirected = false;
      when(() => redirectingGuard.call(any(), any(), any())).thenAnswer((_) {
        if (redirected) {
          return const GuardResult.next();
        }
        redirected = true;
        return GuardResult.redirect(target: redirectTarget);
      });
      lateInitGuardConfiguration.attach('redir', [redirectingGuard]);

      // act
      stateManager.push(profile);
      fa.flushMicrotasks();

      // assert: committed state is the redirect target, not the pushed
      // profile target.
      expect(stateManager.state.route, equals(home));
      expect(stateManager.state.children, hasLength(1));
      expect(
        stateManager.state.children.single.route,
        equals(const YxRoute(id: 'redir')),
      );

      lateInitGuardConfiguration.detach('redir');
    });

    testAsync(
        'detach removes previously-attached guards — a mutation that was '
        'blocked before is now allowed', (fa) {
      // arrange: blocked under default setUp — detach the cancelling guard.
      expect(stateManager.state.children, isEmpty);
      lateInitGuardConfiguration.detach('test');

      // act
      stateManager.push(profile);
      fa.flushMicrotasks();

      // assert: push goes through because nothing cancels anymore.
      expect(stateManager.state.children, hasLength(1));
      expect(stateManager.state.children.single.route, equals(profile));
    });

    testAsync(
        'multiple attach layers stack — any attached key that cancels still '
        'blocks', (fa) {
      // arrange: add a second key on top of the default cancelling one.
      final allowingGuard = RouteNodeGuardMock();
      when(() => allowingGuard.call(any(), any(), any()))
          .thenReturn(const GuardResult.next());
      lateInitGuardConfiguration.attach('also-attached', [allowingGuard]);

      // act
      stateManager.push(profile);
      fa.flushMicrotasks();

      // assert: mutation still cancelled because 'test' guard still cancels,
      // even though 'also-attached' would let through.
      expect(stateManager.state.children, isEmpty);

      lateInitGuardConfiguration.detach('also-attached');
    });

    test(
      'empty attach is a no-op — calling attach with an empty iterable does '
      'not add any guards and does not affect behaviour',
      () {
        // arrange
        lateInitGuardConfiguration
          ..detach('test')
          ..attach('empty', const []);

        // act: reading guards after an empty attach returns whatever was
        // there before (base guards — none in this fixture). Since nothing
        // cancels, a direct mutate must go through.
        stateManager.push(profile);

        // assert
        expect(stateManager.state.children, hasLength(1));
        expect(stateManager.state.children.single.route, equals(profile));

        lateInitGuardConfiguration.detach('empty');
      },
    );
  });
}
