import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/base/route_node_resolver.dart';

void main() {
  group('RouteNodeResolver', () {
    group('FullRouteNodeResolver', () {
      test('resolves route node when arguments match exactly', () {
        // arrange
        const route = YxRoute(id: 'test_route');
        const arguments = {'key1': 'value1', 'key2': 'value2'};
        const resolver =
            RouteNodeResolver.full(route: route, arguments: arguments);
        final rootNode = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(route: route, arguments: arguments),
          ],
        );

        // act
        final actual = resolver.resolve(rootNode);

        // assert
        expect(actual, isNotNull);
        expect(actual?.route, equals(route));
        expect(actual?.arguments, equals(arguments));
      });

      test('resolves when arguments contain JSON-like string values', () {
        // arrange: arguments are still a flat `Map<String, String>`; the
        // values merely *look* like serialized JSON collections, since the
        // map itself only stores strings.
        const route = YxRoute(id: 'complex_route');
        const arguments = {
          'simple_key': 'simple_value',
          'list_as_string': '[1, 2, 3]',
          'map_as_string': '{"nested": "value"}',
        };
        const resolver =
            RouteNodeResolver.full(route: route, arguments: arguments);
        final rootNode = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(route: route, arguments: arguments),
          ],
        );

        // act
        final actual = resolver.resolve(rootNode);

        // assert
        expect(actual, isNotNull);
        expect(actual?.route, equals(route));
        expect(actual?.arguments, equals(arguments));
      });

      test('returns null when arguments differ', () {
        // arrange
        const route = YxRoute(id: 'test_route');
        const searchArguments = {'key1': 'value1', 'key2': 'value2'};
        const nodeArguments = {'key1': 'value1', 'key2': 'different_value'};
        const resolver = RouteNodeResolver.full(
          route: route,
          arguments: searchArguments,
        );
        final rootNode = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(route: route, arguments: nodeArguments),
          ],
        );

        // act
        final actual = resolver.resolve(rootNode);

        // assert
        expect(actual, isNull);
      });

      test('resolves when arguments are empty', () {
        // arrange
        const route = YxRoute(id: 'empty_args_route');
        const emptyArguments = <String, String>{};
        const resolver = RouteNodeResolver.full(
          route: route,
          arguments: emptyArguments,
        );
        final rootNode = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [RouteNode.fromRoute(route: route)],
        );

        // act
        final actual = resolver.resolve(rootNode);

        // assert
        expect(actual, isNotNull);
        expect(actual?.arguments, isEmpty);
      });

      test('resolves when arguments contain special characters', () {
        // arrange
        const route = YxRoute(id: 'special_chars_route');
        const arguments = {
          'json_like': '{"key": "value", "number": 123}',
          'array_like': '[1, 2, {"nested": true}]',
          'unicode': 'test with unicode 🎉',
          'special_chars': r'value with spaces & symbols!@#$%^&*()',
        };
        const resolver =
            RouteNodeResolver.full(route: route, arguments: arguments);
        final rootNode = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(
              route: route,
              arguments: Map.from(arguments),
            ),
          ],
        );

        // act
        final actual = resolver.resolve(rootNode);

        // assert
        expect(actual, isNotNull);
        expect(actual?.arguments, equals(arguments));
      });
    });

    group('RouteIDNodeResolver', () {
      test('resolves route node by ID ignoring arguments', () {
        // arrange
        const route = YxRoute(id: 'target_route');
        const resolver = RouteNodeResolver.id(route: route);
        final rootNode = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(
              route: route,
              arguments: const {'some': 'arguments'},
            ),
          ],
        );

        // act
        final actual = resolver.resolve(rootNode);

        // assert
        expect(actual, isNotNull);
        expect(actual?.route, equals(route));
      });
    });
  });
}
