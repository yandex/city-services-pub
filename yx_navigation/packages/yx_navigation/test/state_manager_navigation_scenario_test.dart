import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_navigator.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/base/route_node_resolver.dart';
import 'package:yx_navigation/src/state/state_manager.dart';

void main() {
  const root = YxRoute(id: 'root');
  const settingsRoute = YxRoute(id: 'settings');
  const mapRoute = YxRoute(id: 'map');
  const profileRoute = YxRoute(id: 'Profile');

  const orderFeatureRoute = YxRoute(id: 'Order');
  const orderFeatureDetailsSubRoute = YxRoute(id: 'Order Details');
  const orderFeaturePrioritySubRoute = YxRoute(id: 'Order Priority Details');

  late RouteNode initialNode;
  late RouteNodeStateManager parentStateManager;

  setUp(() {
    initialNode = RouteNode.fromRoute(
      route: root,
      children: [
        RouteNode.fromRoute(route: settingsRoute),
        RouteNode.fromRoute(
          route: mapRoute,
          children: [RouteNode.fromRoute(route: orderFeatureRoute)],
        ),
        RouteNode.fromRoute(route: profileRoute),
      ],
    );

    parentStateManager = RouteNodeStateManager(routeNode: initialNode);
  });

  group('NavigationController', () {
    test(
      'manipulates its own feature stack and reflects changes in parent state manager',
      () {
        // arrange
        const resolver = RouteIDNodeResolver(route: orderFeatureRoute);

        // act: simulate navigating inside the order feature — push a
        // detail sub-route, then push priority on top, then pop priority.
        NavigationController.node(
          stateManager: parentStateManager,
          nodeResolver: resolver,
        )
          ..mutate((state) {
            final orderFeatureSubRouteNode = RouteNode.fromRoute(
              route: orderFeatureDetailsSubRoute,
            );
            return state..add(orderFeatureSubRouteNode);
          })
          ..push(orderFeaturePrioritySubRoute)
          ..pop();

        // assert: only details sub-route remains — resolved node identity
        // is the order-feature route itself, with exactly one child node
        // carrying the details route id (no arguments / no extra attached).
        final actualResolveNode = resolver.resolve(parentStateManager.state);
        expect(actualResolveNode, isNotNull);
        expect(actualResolveNode!.route, equals(orderFeatureRoute));
        expect(actualResolveNode.children, hasLength(1));
        final actualDetailsChild = actualResolveNode.children.single;
        expect(actualDetailsChild.route, equals(orderFeatureDetailsSubRoute));
        expect(actualDetailsChild.children, isEmpty);
      },
    );

    test(
      'keeps updates visible in the root state manager across multiple feature controllers',
      () async {
        // arrange: map feature controller.
        const mapResolver = RouteIDNodeResolver(route: mapRoute);
        final mapFeatureStateManager = NavigationController.node(
          nodeResolver: mapResolver,
          stateManager: parentStateManager,
        );

        // arrange: order feature controller, nested inside map.
        const orderResolver = RouteIDNodeResolver(route: orderFeatureRoute);
        final orderFeatureStateManager = NavigationController.node(
          stateManager: parentStateManager,
          nodeResolver: orderResolver,
        )..push(orderFeatureDetailsSubRoute);

        await orderFeatureStateManager.close();

        // assert: order feature shows the pushed details child.
        var actualResolveNode = orderResolver.resolve(parentStateManager.state);
        expect(actualResolveNode, isNotNull);
        expect(actualResolveNode?.children, hasLength(1));
        expect(
          actualResolveNode?.children.firstOrNull?.route,
          equals(orderFeatureDetailsSubRoute),
        );

        // act: push a new route inside the map feature.
        const newRoute = YxRoute(id: 'new route');
        mapFeatureStateManager.push(newRoute);

        // assert: map feature has the new route at the top.
        actualResolveNode = mapResolver.resolve(parentStateManager.state);
        expect(actualResolveNode, isNotNull);
        expect(actualResolveNode?.children, hasLength(2));
        expect(
          actualResolveNode?.children.lastOrNull?.route,
          equals(newRoute),
        );
      },
    );
  });
}
