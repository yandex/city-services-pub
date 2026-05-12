import 'package:test/test.dart';
import 'package:yx_navigation/src/base/active_route_controller.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_navigator.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/base/route_node_resolver.dart';
import 'package:yx_navigation/src/extensions/route_node_extensions.dart';
import 'package:yx_navigation/src/guard/default/navigate_to_indexed_stack_node_guard.dart';
import 'package:yx_navigation/src/guard/guard_configuration.dart';
import 'package:yx_navigation/src/state/state_manager.dart';

import '../helpers/async.dart';

class TestRoutes {
  static const YxRoute root = YxRoute(id: 'root');
  static const YxRoute indexedStack = YxRoute(id: 'indexed_stack');
  static const YxRoute tab1 = YxRoute(id: 'tab1');
  static const YxRoute tab2 = YxRoute(id: 'tab2');
  static const YxRoute tab3 = YxRoute(id: 'tab3');
  static const YxRoute extraRoute = YxRoute(id: 'extra_route');
}

void main() {
  late RouteNodeStateManager stateManager;
  late NavigationController indexedStackController;
  late RouteNode initialNode;

  setUp(() {
    final guard = NavigateToIndexedStackNodeGuard(
      route: TestRoutes.indexedStack,
      declaredRoutes: [TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3],
    );

    initialNode = TestRoutes.root.toNode();

    stateManager = RouteNodeStateManager(
      routeNode: initialNode,
      routeNodeGuard: GuardConfiguration(guards: [guard]),
    );

    const resolver = RouteIDNodeResolver(route: TestRoutes.indexedStack);
    indexedStackController = NavigationController.node(
      stateManager: stateManager,
      nodeResolver: resolver,
    );
  });

  tearDown(() async {
    await stateManager.close();
  });

  group('NavigateToIndexedStackNodeGuard scenarios', () {
    group('Initialization', () {
      test('creates indexed stack node with all declared children when pushed',
          () {
        // act
        stateManager.push(TestRoutes.indexedStack);

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3]),
        );
      });

      test('creates indexed stack node when mutated via mutate', () {
        // act
        stateManager
            .mutate((node) => node..add(TestRoutes.indexedStack.toNode()));

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3]),
        );
      });
    });

    group('Protection against child removal', () {
      setUp(() {
        stateManager.push(TestRoutes.indexedStack);
      });

      test('does not remove children when mutate clears them', () {
        // act
        indexedStackController.mutate((node) => node..setChildren([]));

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3]),
        );
      });

      test('does not replace children when mutate sets unknown routes', () {
        // act
        indexedStackController.mutate(
          (node) => node..setChildren([TestRoutes.extraRoute.toNode()]),
        );

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3]),
        );
      });

      test('does not remove some children when mutate sets a subset', () {
        // act
        indexedStackController.mutate(
          (node) => node..setChildren([TestRoutes.tab1.toNode()]),
        );

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3]),
        );
      });

      test('restores children when they are removed externally', () {
        // act
        stateManager.mutate((node) {
          final mutable = node.toMutable();
          final indexedNode = mutable.findByRoute(TestRoutes.indexedStack);
          if (indexedNode != null) {
            indexedNode.setChildren([]);
          }
          return mutable;
        });

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3]),
        );
      });
    });

    group('Operations with children', () {
      setUp(() {
        stateManager.push(TestRoutes.indexedStack);
      });

      test('pops extra route while keeping declared children intact', () {
        // arrange
        indexedStackController
          ..push(TestRoutes.extraRoute)
          // act
          ..pop();

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3]),
        );
      });

      test('popAll keeps declared children in place', () {
        // arrange
        indexedStackController
          ..push(TestRoutes.extraRoute)
          ..push(const YxRoute(id: 'extra2'))
          // act
          ..popAll();

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3]),
        );
      });
    });

    group('ActiveRouteController scenarios', () {
      late ActiveRouteController activeRouteController;

      setUp(() {
        stateManager.push(TestRoutes.indexedStack);
        activeRouteController = indexedStackController;
      });

      test('switches active tab and reorders children', () {
        // act
        activeRouteController.setActiveRoute(TestRoutes.tab2);

        // assert
        expect(activeRouteController.activeRoute, equals(TestRoutes.tab2));
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab3, TestRoutes.tab2]),
        );
      });

      test('reorders children across multiple active-route changes', () {
        // act
        activeRouteController
          ..setActiveRoute(TestRoutes.tab2)
          ..setActiveRoute(TestRoutes.tab3)
          ..setActiveRoute(TestRoutes.tab1);

        // assert
        expect(activeRouteController.activeRoute, equals(TestRoutes.tab1));
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab2, TestRoutes.tab3, TestRoutes.tab1]),
        );
      });

      test('reports correct active route via isRouteActive', () {
        // act
        activeRouteController.setActiveRoute(TestRoutes.tab2);

        // assert
        expect(activeRouteController.isRouteActive(TestRoutes.tab2), isTrue);
        expect(activeRouteController.isRouteActive(TestRoutes.tab1), isFalse);
        expect(activeRouteController.isRouteActive(TestRoutes.tab3), isFalse);
      });

      testAsync('emits active route changes via stream', (fa) {
        // arrange
        final actualRoutes = <YxRoute?>[];
        final subscription =
            activeRouteController.activeRouteStream.listen(actualRoutes.add);

        // act
        activeRouteController
          ..setActiveRoute(TestRoutes.tab2)
          ..setActiveRoute(TestRoutes.tab3);
        fa.flushMicrotasks();

        // assert: exact sequence emitted, order matters — tab2 switched
        // before tab3.
        expect(
          actualRoutes,
          orderedEquals(<YxRoute?>[TestRoutes.tab2, TestRoutes.tab3]),
        );

        subscription.cancel();
      });

      test('moves newly active tab to the end', () {
        // act
        activeRouteController.setActiveRoute(TestRoutes.tab2);

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab3, TestRoutes.tab2]),
        );
        expect(activeRouteController.activeRoute, equals(TestRoutes.tab2));
      });

      test('reorders children correctly on multiple active-route switches', () {
        // act
        activeRouteController.setActiveRoute(TestRoutes.tab3);

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3]),
        );

        // act
        activeRouteController.setActiveRoute(TestRoutes.tab1);

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab2, TestRoutes.tab3, TestRoutes.tab1]),
        );

        // act
        activeRouteController.setActiveRoute(TestRoutes.tab2);

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab3, TestRoutes.tab1, TestRoutes.tab2]),
        );
      });

      test('keeps order when setActiveRoute is called on the active route', () {
        // arrange
        activeRouteController.setActiveRoute(TestRoutes.tab2);
        final expectedOrder =
            indexedStackController.state?.children.map((e) => e.route).toList();

        // act
        activeRouteController.setActiveRoute(TestRoutes.tab2);

        // assert
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals(expectedOrder ?? []),
        );
        expect(activeRouteController.activeRoute, equals(TestRoutes.tab2));
      });
    });

    group('Complex scenarios', () {
      setUp(() {
        stateManager.push(TestRoutes.indexedStack);
      });

      test('nested navigation inside a tab leaves indexed children intact', () {
        // arrange
        const tab1Route = TestRoutes.tab1;
        const tab1Resolver = RouteIDNodeResolver(route: tab1Route);
        final tab1Controller = NavigationController.node(
          stateManager: stateManager,
          nodeResolver: tab1Resolver,
        );

        // act
        const nestedRoute = YxRoute(id: 'nested_in_tab1');
        tab1Controller.push(nestedRoute);

        // assert
        expect(
          tab1Controller.state?.children.map((e) => e.route),
          orderedEquals([nestedRoute]),
        );
        expect(
          indexedStackController.state?.children.map((e) => e.route),
          orderedEquals([TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3]),
        );
      });
    });
  });
}
