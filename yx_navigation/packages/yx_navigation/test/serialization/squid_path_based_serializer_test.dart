import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/serialization/serializers/squid_path_based_serializer.dart';

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

  group('SquidPathBasedSerializer', () {
    test('round trip serialization works', () {
      // Test that encoding and decoding produces the same result
      final encoded = SquidPathBasedSerializer.toUri(node);
      final decoded = SquidPathBasedSerializer.fromUri(encoded);

      expect(decoded, equals(node));
    });

    test('serializes to path (not fragment)', () {
      final encoded = SquidPathBasedSerializer.toUri(node);

      expect(encoded.path.isNotEmpty, isTrue);
      expect(encoded.fragment, isEmpty);
      expect(encoded.path.startsWith('/'), isTrue);
    });

    test('reserved symbols are encoded', () {
      // Note: '$' is used as separator in squid format
      // '&' and '=' are used in query string format
      // So we test other reserved symbols like '.' and '/'
      final node = RouteNode.fromRoute(
        route: const YxRoute(id: 'a${SquidPathBasedSerializer.prefix}b/\\'),
        arguments: const {
          'c${SquidPathBasedSerializer.prefix}d': r':/\\value',
        },
      );

      final encoded = SquidPathBasedSerializer.toUri(node);
      final decoded = SquidPathBasedSerializer.fromUri(encoded);

      expect(decoded, equals(node));
    });

    test('handles empty path gracefully', () {
      final uri = Uri();
      decodeFunction() => SquidPathBasedSerializer.fromUri(uri);
      expect(decodeFunction, throwsFormatException);
    });

    test('using multiple separators in a segment throws an error', () {
      // Create URI with encoded path containing multiple separators
      final pathSegment = Uri.encodeComponent(r'home$?user=watermelon');
      final pathSegment2 =
          Uri.encodeComponent(r'.level1-1$?arg1=value1$?arg2=value2');
      final uri = Uri(path: '/$pathSegment/$pathSegment2');

      decodeFunction() => SquidPathBasedSerializer.fromUri(uri);
      expect(decodeFunction, throwsFormatException);
    });

    group('OAuth callback scenarios', () {
      test('parses path-based URL with query params from third party', () {
        // Simulates OAuth callback where third party adds query params
        final uri = Uri.parse(
          'http://localhost/'
          'root/.yandex-callback?state=no_invite&code=some_code&cid=some_cid',
        );

        final decoded = SquidPathBasedSerializer.fromUri(uri);

        expect(decoded.route.id, equals('root'));
        expect(decoded.children.length, equals(1));
        expect(decoded.children.first.route.id, equals('yandex-callback'));
        // Query params are NOT automatically merged - that's handled by
        // PrettyUriStateSerialization with mergeQueryParams=true
      });

      test('simple path-based navigation state', () {
        final uri = Uri.parse('/root/.dashboard');
        final decoded = SquidPathBasedSerializer.fromUri(uri);

        expect(decoded.route.id, equals('root'));
        expect(decoded.children.length, equals(1));
        expect(decoded.children.first.route.id, equals('dashboard'));
      });

      test('path-based with arguments via round trip', () {
        // For path-based, arguments with special chars need to go through
        // proper encoding, so we test round-trip instead of raw parsing
        final originalNode = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(
              route: const YxRoute(id: 'profile'),
              arguments: const {'userId': '123'},
            ),
          ],
        );

        final encoded = SquidPathBasedSerializer.toUri(originalNode);
        final decoded = SquidPathBasedSerializer.fromUri(encoded);

        expect(decoded.route.id, equals('root'));
        expect(decoded.children.first.route.id, equals('profile'));
        expect(decoded.children.first.arguments['userId'], equals('123'));
      });
    });
  });
}
