import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
// internal type, not exported
import 'package:yx_navigation/src/serialization/serializers/uri_path_based_serializer.dart';

void main() {
  group('UriPathBasedSerializer', () {
    group('toUri', () {
      test('serialized as expected', () {
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
            ),
            RouteNode.fromRoute(
              route: const YxRoute(id: 'level1-2'),
            ),
          ],
        );

        final encoded = UriPathBasedSerializer.toUri(node);
        final decoded = UriPathBasedSerializer.fromUri(encoded);

        expect(decoded, equals(node));
        // Path-based: starts with / not #
        expect(encoded.path.startsWith('/'), isTrue);
        expect(encoded.fragment, isEmpty);
      });

      test('reserved symbols are encoded correctly', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'a[]{}"b'),
          arguments: const {
            'key[]{}"': 'value[]{}"',
            'another': r'test&$()' "'",
          },
        );

        final encoded = UriPathBasedSerializer.toUri(node);
        final decoded = UriPathBasedSerializer.fromUri(encoded);

        expect(decoded, equals(node));
      });

      test('empty arguments are handled correctly', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'route_without_args'),
        );

        final encoded = UriPathBasedSerializer.toUri(node);
        final decoded = UriPathBasedSerializer.fromUri(encoded);

        expect(decoded, equals(node));
      });

      test('deep nesting is handled correctly', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(
              route: const YxRoute(id: 'level1'),
              children: [
                RouteNode.fromRoute(
                  route: const YxRoute(id: 'level2'),
                  children: [
                    RouteNode.fromRoute(
                      route: const YxRoute(id: 'level3'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final encoded = UriPathBasedSerializer.toUri(node);
        final decoded = UriPathBasedSerializer.fromUri(encoded);

        expect(decoded, equals(node));
      });

      test('cyrillic unicode characters are handled correctly', () {
        // Cyrillic route id + Cyrillic key/value + multi-byte emoji —
        // exercises the full UTF-8 round-trip through the path-based
        // serializer, which percent-encodes non-ASCII segments.
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'route-с-кириллицей'),
          arguments: const {
            'ключ': 'значение',
            'emoji': '🚀🎉',
          },
        );

        final encoded = UriPathBasedSerializer.toUri(node);
        final decoded = UriPathBasedSerializer.fromUri(encoded);

        expect(decoded, equals(node));
      });

      test('chinese unicode characters are handled correctly', () {
        // Non-ASCII route id + non-ASCII key/value + multi-byte emoji
        // exercises the full UTF-8 round-trip through the path-based
        // serializer, which percent-encodes non-ASCII segments.
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'route-with-中文'),
          arguments: const {
            'key-中文': 'value-中文',
            'emoji': '🚀🎉',
          },
        );

        final encoded = UriPathBasedSerializer.toUri(node);
        final decoded = UriPathBasedSerializer.fromUri(encoded);

        expect(decoded, equals(node));
      });
    });

    group('fromUri', () {
      test('handles empty path gracefully', () {
        final uri = Uri(path: '');
        decodeFunction() => UriPathBasedSerializer.fromUri(uri);
        expect(decodeFunction, throwsFormatException);
      });

      test('handles path with leading slash', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
        );

        final encoded = UriPathBasedSerializer.toUri(node);
        // Verify it has leading slash
        expect(encoded.path.startsWith('/'), isTrue);

        final decoded = UriPathBasedSerializer.fromUri(encoded);
        expect(decoded, equals(node));
      });
    });

    group('OAuth callback scenarios', () {
      test('path-based URL preserves query params separately', () {
        // Third party adds query params to redirect URL
        final uri = Uri.parse(
          'http://localhost/'
          "('cnQ':('aWQ':'cm9vdA'))?state=no_invite&code=some_code",
        );

        // Query params are accessible via uri.queryParameters
        expect(uri.queryParameters['state'], equals('no_invite'));
        expect(uri.queryParameters['code'], equals('some_code'));

        // Path can be parsed independently
        final decoded = UriPathBasedSerializer.fromUri(uri);
        expect(decoded.route.id, equals('root'));
      });
    });
  });
}
