import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
// internal type, not exported
import 'package:yx_navigation/src/base/route_node_util.dart';
import 'package:yx_navigation/src/extensions/route_node_extensions.dart';

void main() {
  late YxRoute rootRoute;
  late YxRoute mapRoute;
  late YxRoute orderRoute;
  late RouteNode rootRouteNode;
  late RouteNode mapRouteNode;
  late RouteNode orderRouteNode;

  setUp(() {
    rootRoute = const YxRoute(id: 'root');
    mapRoute = const YxRoute(id: 'map');
    orderRoute = const YxRoute(id: 'order');
    orderRouteNode = RouteNode.fromRoute(route: orderRoute);
    mapRouteNode = RouteNode.fromRoute(
      route: mapRoute,
      children: [orderRouteNode],
    );
    rootRouteNode = RouteNode.fromRoute(
      route: rootRoute,
      children: [mapRouteNode],
    );
  });

  group('RouteNodeUtil', () {
    group('findByRoute method', () {
      test('finds nested node by route using default recursive search', () {
        // act
        final actual = RouteNodeUtil.findByRoute(rootRouteNode, mapRoute);

        // assert
        expect(actual, equals(mapRouteNode));
      });

      test('finds direct child node when recursive is false', () {
        // act
        final actual = RouteNodeUtil.findByRoute(
          rootRouteNode,
          mapRoute,
          recursive: false,
        );

        // assert
        expect(actual, equals(mapRouteNode));
      });

      test('finds deeply nested node when recursive is true', () {
        // act
        final actual = RouteNodeUtil.findByRoute(rootRouteNode, orderRoute);

        // assert
        expect(actual, equals(orderRouteNode));
      });

      test(
          'returns null when node is deeper than one level and recursive is false',
          () {
        // act
        final actual = RouteNodeUtil.findByRoute(
          rootRouteNode,
          orderRoute,
          recursive: false,
        );

        // assert
        expect(actual, isNull);
      });
    });

    group('compareNodes method', () {
      test('reports added children in diff result', () {
        // arrange
        final originalNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [
            const YxRoute(id: 'a').toNode(),
            const YxRoute(id: 'b').toNode(),
          ],
        );
        final targetNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [
            const YxRoute(id: 'b').toNode(),
            const YxRoute(id: 'a').toNode(),
            const YxRoute(id: 'added').toNode(),
          ],
        );

        // act
        final actual = RouteNodeUtil.compareNodes(originalNode, targetNode);

        // assert
        expect(
          actual.added.values,
          unorderedEquals([const YxRoute(id: 'added').toNode()]),
        );
      });

      test('reports removed children in diff result', () {
        // arrange
        final originalNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [
            const YxRoute(id: 'a').toNode(),
            const YxRoute(id: 'toRemove').toNode(),
          ],
        );
        final targetNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [const YxRoute(id: 'a').toNode()],
        );

        // act
        final actual = RouteNodeUtil.compareNodes(originalNode, targetNode);

        // assert
        expect(
          actual.removed.values,
          unorderedEquals([const YxRoute(id: 'toRemove').toNode()]),
        );
      });

      test('reports updated children when only their arguments change', () {
        // arrange
        final originalNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [
            const YxRoute(id: 'a').toNode(),
            const YxRoute(id: 'toUpdated').toNode(),
          ],
        );
        final targetNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [
            const YxRoute(id: 'a').toNode(),
            const YxRoute(id: 'toUpdated').toNode(arguments: {'key1': 'new'}),
          ],
        );

        // act
        final actual = RouteNodeUtil.compareNodes(originalNode, targetNode);

        // assert
        expect(
          actual.updates.values.map((node) => node.originalState).toList(),
          unorderedEquals([const YxRoute(id: 'toUpdated').toNode()]),
        );
      });

      test('does not add parent to updates when children are not added/removed',
          () {
        // arrange
        final originalNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [
            const YxRoute(id: 'a').toNode(),
            const YxRoute(id: 'toUpdated').toNode(),
          ],
        );
        final targetNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [
            const YxRoute(id: 'a').toNode(),
            const YxRoute(id: 'toUpdated').toNode(arguments: {'key1': 'new'}),
          ],
        );

        // act
        final actual = RouteNodeUtil.compareNodes(originalNode, targetNode);

        // assert
        expect(
          actual.updates.values.map((node) => node.originalState).toList(),
          isNot(contains(originalNode)),
        );
      });

      test('adds parent as updated when children collection has added nodes',
          () {
        // arrange
        final originalNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [
            const YxRoute(id: 'a').toNode(),
            const YxRoute(id: 'b').toNode(),
          ],
        );
        final targetNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [
            const YxRoute(id: 'a').toNode(),
            const YxRoute(id: 'b').toNode(),
            const YxRoute(id: 'added').toNode(),
          ],
        );

        // act
        final actual = RouteNodeUtil.compareNodes(originalNode, targetNode);

        // assert
        expect(
          actual.updates.values.map((node) => node.originalState).toList(),
          contains(originalNode),
        );
        expect(
          actual.added.values,
          unorderedEquals([const YxRoute(id: 'added').toNode()]),
        );
      });

      test('adds parent as updated when children collection has removed nodes',
          () {
        // arrange
        final originalNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [
            const YxRoute(id: 'a').toNode(),
            const YxRoute(id: 'removed').toNode(),
          ],
        );
        final targetNode = const YxRoute(id: 'root').toNode(
          arguments: {'key1': 'old'},
          children: [const YxRoute(id: 'a').toNode()],
        );

        // act
        final actual = RouteNodeUtil.compareNodes(originalNode, targetNode);

        // assert
        expect(
          actual.updates.values.map((node) => node.originalState).toList(),
          contains(originalNode),
        );
        expect(
          actual.removed.values,
          unorderedEquals([const YxRoute(id: 'removed').toNode()]),
        );
      });
    });
  });
}
