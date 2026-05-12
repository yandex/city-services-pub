import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/serialization/serializers/squid_fragment_based_serializer.dart';

void main() {
  final node = RouteNode.fromRoute(
    route: const YxRoute(id: 'home'),
    arguments: const {
      'user': 'watermelon=good',
    },
    children: [
      RouteNode.fromRoute(
        route: const YxRoute(id: 'level1-1'),
        arguments: const {
          'arg1': 'value1',
          'arg2': 'value2',
        },
        children: [
          RouteNode.fromRoute(
            route: const YxRoute(id: 'level2'),
            children: [
              RouteNode.fromRoute(
                route: const YxRoute(id: 'leve3-1'),
                children: [
                  RouteNode.fromRoute(
                    route: const YxRoute(id: 'leve4-1'),
                  ),
                  RouteNode.fromRoute(
                    route: const YxRoute(id: 'leve4-2'),
                  ),
                ],
              ),
              RouteNode.fromRoute(
                route: const YxRoute(id: 'leve3-2'),
                children: [
                  RouteNode.fromRoute(
                    route: const YxRoute(id: 'leve4-1'),
                  ),
                  RouteNode.fromRoute(
                    route: const YxRoute(id: 'leve4-2'),
                    children: [
                      RouteNode.fromRoute(
                        route: const YxRoute(id: 'level5'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
      RouteNode.fromRoute(
        route: const YxRoute(id: 'level1-1'),
      ),
    ],
  );

  const rawString =
      r'#/home$?user=watermelon%3Dgood/.level1-1$?arg1=value1&arg2=value2/..level2/...leve3-1/....leve4-1/....leve4-2/...leve3-2/....leve4-1/....leve4-2/.....level5/.level1-1';
  group('SquidFragmentBasedSerializer', () {
    test('serialized as expected', () {
      final encoded = SquidFragmentBasedSerializer.toUri(node);
      final expected = Uri.parse(rawString);

      expect(encoded, equals(expected));
    });

    test('deserialized as expected', () {
      final uri = Uri.parse(rawString);
      final decoded = SquidFragmentBasedSerializer.fromUri(uri);

      expect(decoded, equals(node));
    });

    test('reserved symbols are encoded', () {
      final node = RouteNode.fromRoute(
        route:
            const YxRoute(id: 'a${SquidFragmentBasedSerializer.prefix}\$b/\\'),
        arguments: const {
          'c${SquidFragmentBasedSerializer.prefix}d': r'$$?&=:/\\',
        },
      );

      final encoded = SquidFragmentBasedSerializer.toUri(node);
      final decoded = SquidFragmentBasedSerializer.fromUri(encoded);

      expect(decoded, equals(node));
    });

    test('handles empty fragment gracefully', () {
      final uri = Uri();
      decodeFunction() => SquidFragmentBasedSerializer.fromUri(uri);
      expect(decodeFunction, throwsFormatException);
    });

    test('using multiple separators in a segment throws an error', () {
      final uri = Uri.parse(
        r'#/home$?user=watermelon%3Dgood/.level1-1$?arg1=value1$?arg2=value2',
      );
      decodeFunction() => SquidFragmentBasedSerializer.fromUri(uri);
      expect(decodeFunction, throwsFormatException);
    });
  });
}
