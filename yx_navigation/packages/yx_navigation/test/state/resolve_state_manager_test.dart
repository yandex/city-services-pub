import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_navigator.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/base/route_node_resolver.dart';
import 'package:yx_navigation/src/state/state_manager.dart';

import '../helpers/async.dart';
import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

void main() {
  late YxRoute home;
  late YxRoute profile;
  late RouteNode routeNode;
  late RouteNodeStateManager stateManager;
  late RouteNodeResolver routeNodeResolver;
  late NavigationController profileNavigationController;

  setUpAll(registerFallbacks);

  setUp(() {
    home = const YxRoute(id: 'home');
    profile = const YxRoute(id: 'profile');
    routeNode = RouteNode.fromRoute(route: home);
    stateManager = RouteNodeStateManager(routeNode: routeNode);
    routeNodeResolver = RouteIDNodeResolver(route: profile);
    profileNavigationController = NavigationController.node(
      stateManager: stateManager,
      nodeResolver: routeNodeResolver,
    );
  });

  tearDown(() async {
    await profileNavigationController.close();
    await stateManager.close();
  });

  group('ResolveStateManager', () {
    testAsync('exposes resolved profile subtree after pushing profile route',
        (fa) {
      // assert: before push profile subtree is null.
      expect(profileNavigationController.state, isNull);

      // act: push profile on root stack and drain microtasks.
      stateManager.push(profile);
      fa.flushMicrotasks();

      // assert: profile node is now the first child of root, and the
      // resolved state exposed by the profile controller is the exact same
      // node (no wrapper/copy) with the profile route and no children yet.
      final actualProfileRouteNode = stateManager.state.children.firstOrNull;
      expect(actualProfileRouteNode?.route, equals(profile));
      expect(profileNavigationController.state, equals(actualProfileRouteNode));
      expect(profileNavigationController.state?.route, equals(profile));
      expect(profileNavigationController.state?.children, isEmpty);

      // act: push home under profile through the profile controller.
      profileNavigationController.push(home);

      // assert: profile subtree contains home as child.
      final actualProfileAfterPush = stateManager.state.children.firstOrNull;
      expect(actualProfileAfterPush?.route, equals(profile));
      expect(
        actualProfileAfterPush?.children.firstOrNull?.route,
        equals(home),
      );
    });

    testAsync(
      'calls resolver once per event even with multiple subscribers',
      (fa) {
        // arrange: solitary mock — return a fixed node so the test only
        // measures invocation count, not the real resolver's behaviour.
        final expectedNode = makeNode(route: profile);
        final resolverMock = RouteNodeResolverMock();
        when(() => resolverMock.resolve(any())).thenReturn(expectedNode);
        final controller = NavigationController.node(
          stateManager: stateManager,
          nodeResolver: resolverMock,
        );

        final events1 = <RouteNode?>[];
        final events2 = <RouteNode?>[];
        final events3 = <RouteNode?>[];

        final sub1 = controller.stream.listen(events1.add);
        final sub2 = controller.stream.listen(events2.add);
        final sub3 = controller.stream.listen(events3.add);

        // act
        stateManager.push(profile);
        fa.flushMicrotasks();

        // assert: resolver invoked once despite three subscribers.
        verify(() => resolverMock.resolve(any())).called(1);
        expect(events1, hasLength(1));
        expect(events2, hasLength(1));
        expect(events3, hasLength(1));
        expect(events1.first?.route, equals(profile));
        expect(events2.first?.route, equals(profile));
        expect(events3.first?.route, equals(profile));

        sub1.cancel();
        sub2.cancel();
        sub3.cancel();
        controller.close();
      },
    );

    testAsync('broadcasts events to late subscribers as they attach', (fa) {
      // arrange
      const settings = YxRoute(id: 'settings');
      final controller = NavigationController.node(
        stateManager: stateManager,
        nodeResolver: routeNodeResolver,
      );

      final events1 = <RouteNode?>[];
      final events2 = <RouteNode?>[];

      final sub1 = controller.stream.listen(events1.add);

      // act: push profile, then subscribe a second listener before next event.
      stateManager.push(profile);
      fa.flushMicrotasks();

      final sub2 = controller.stream.listen(events2.add);

      // act: push a second event under profile.
      controller.push(settings);
      fa.flushMicrotasks();

      // assert: first subscriber sees both events, second only the second.
      expect(events1, hasLength(2));
      expect(events1.first?.route, equals(profile));
      expect(events1.last?.children.firstOrNull?.route, equals(settings));
      expect(events2, hasLength(1));
      expect(events2.first?.children.firstOrNull?.route, equals(settings));

      sub1.cancel();
      sub2.cancel();
      controller.close();
    });
  });
}
