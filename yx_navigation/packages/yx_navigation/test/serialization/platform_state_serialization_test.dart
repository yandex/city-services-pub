// ignore_for_file: avoid_redundant_argument_values

import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/serialization/platform_state_serialization.dart';

void main() {
  group('PrettyUriStateSerialization', () {
    group('UriStrategy.fragment (default)', () {
      const serialization = PrettyUriStateSerialization();

      test('serializes to fragment and roundtrips back to an equal node', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(route: const YxRoute(id: 'dashboard')),
          ],
        );

        final uri = serialization.convert(node);

        // fragment strategy uses the URI fragment, never the path.
        expect(uri.path, isEmpty);
        expect(uri.fragment, equals('/root/.dashboard'));
        // convert → parse roundtrips to an equal tree.
        expect(serialization.parse(uri), equals(node));
      });

      test('parses from fragment', () {
        final uri = Uri.parse('#/root/.dashboard');
        final node = serialization.parse(uri);

        expect(node.route.id, equals('root'));
        expect(node.children.first.route.id, equals('dashboard'));
      });
    });

    group('UriStrategy.path', () {
      const serialization = PrettyUriStateSerialization(
        strategy: UriStrategy.path,
      );

      test('serializes to path and roundtrips back to an equal node', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(route: const YxRoute(id: 'dashboard')),
          ],
        );

        final uri = serialization.convert(node);

        // path strategy uses the URI path, never the fragment.
        expect(uri.fragment, isEmpty);
        expect(uri.path, equals('/root/.dashboard'));
        // convert → parse roundtrips to an equal tree.
        expect(serialization.parse(uri), equals(node));
      });

      test('parses from path', () {
        final uri = Uri.parse('/root/.dashboard');
        final node = serialization.parse(uri);

        expect(node.route.id, equals('root'));
        expect(node.children.first.route.id, equals('dashboard'));
      });
    });

    group('mergeQueryParams', () {
      test('merges query params into deepest child (fragment strategy)', () {
        const serialization = PrettyUriStateSerialization(
          strategy: UriStrategy.fragment,
          mergeQueryParams: true,
        );

        // Query params BEFORE fragment (in URL, ? comes before #)
        final uri = Uri.parse(
          'http://localhost/?state=no_invite&code=some_code'
          '#/root/.yandex-callback',
        );

        final node = serialization.parse(uri);

        expect(node.route.id, equals('root'));
        expect(node.children.first.route.id, equals('yandex-callback'));
        // Query params are accessible via uri.queryParameters even with fragment
        expect(node.children.first.arguments['state'], equals('no_invite'));
        expect(node.children.first.arguments['code'], equals('some_code'));
      });

      test('merges query params into deepest child (path strategy)', () {
        const serialization = PrettyUriStateSerialization(
          strategy: UriStrategy.path,
          mergeQueryParams: true,
        );

        final uri = Uri.parse(
          'http://localhost/'
          'root/.yandex-callback?state=no_invite&code=some_code&cid=some_cid',
        );

        final node = serialization.parse(uri);

        expect(node.route.id, equals('root'));
        expect(node.children.first.route.id, equals('yandex-callback'));
        expect(node.children.first.arguments['state'], equals('no_invite'));
        expect(node.children.first.arguments['code'], equals('some_code'));
        expect(node.children.first.arguments['cid'], equals('some_cid'));
      });

      test('merges into deepest child with multiple levels', () {
        const serialization = PrettyUriStateSerialization(
          strategy: UriStrategy.path,
          mergeQueryParams: true,
        );

        final uri = Uri.parse(
          '/root/.level1/..level2/...level3?oauth_token=abc123',
        );

        final node = serialization.parse(uri);

        // Root should not have the param
        expect(node.arguments['oauth_token'], isNull);

        // level1 should not have the param
        expect(node.children.first.arguments['oauth_token'], isNull);

        // level2 should not have the param
        expect(
          node.children.first.children.first.arguments['oauth_token'],
          isNull,
        );

        // level3 (deepest) should have the param
        expect(
          node.children.first.children.first.children.first
              .arguments['oauth_token'],
          equals('abc123'),
        );
      });

      test('preserves existing arguments when merging', () {
        const serialization = PrettyUriStateSerialization(
          strategy: UriStrategy.path,
          mergeQueryParams: true,
        );

        // First create node with existing arguments, then add query params
        final originalNode = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(
              route: const YxRoute(id: 'callback'),
              arguments: const {'existing': 'value'},
            ),
          ],
        );

        // Encode the node
        final encodedUri = serialization.convert(originalNode);
        // Add query params that should be merged
        final uriWithQueryParams = encodedUri.replace(
          queryParameters: {'new_param': 'new_value'},
        );

        final node = serialization.parse(uriWithQueryParams);

        expect(node.children.first.arguments['existing'], equals('value'));
        expect(node.children.first.arguments['new_param'], equals('new_value'));
      });

      test('does not merge when mergeQueryParams is false', () {
        const serialization = PrettyUriStateSerialization(
          strategy: UriStrategy.path,
          mergeQueryParams: false,
        );

        final uri = Uri.parse(
          '/root/.yandex-callback?state=no_invite&code=some_code',
        );

        final node = serialization.parse(uri);

        expect(node.children.first.arguments['state'], isNull);
        expect(node.children.first.arguments['code'], isNull);
      });

      test('handles empty query params', () {
        const serialization = PrettyUriStateSerialization(
          strategy: UriStrategy.path,
          mergeQueryParams: true,
        );

        final uri = Uri.parse('/root/.dashboard');
        final node = serialization.parse(uri);

        expect(node.route.id, equals('root'));
        expect(node.children.first.route.id, equals('dashboard'));
        expect(node.children.first.arguments, isEmpty);
      });
    });
  });

  group('UriStringStateSerialization', () {
    group('UriStrategy.fragment (default)', () {
      const serialization = UriStringStateSerialization();

      test('serializes to fragment', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
        );

        final uri = serialization.convert(node);

        expect(uri.fragment.isNotEmpty, isTrue);
        expect(uri.path, isEmpty);
      });

      test('round trip works', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          arguments: const {'key': 'value'},
          children: [
            RouteNode.fromRoute(route: const YxRoute(id: 'child')),
          ],
        );

        final uri = serialization.convert(node);
        final parsed = serialization.parse(uri);

        expect(parsed, equals(node));
      });
    });

    group('UriStrategy.path', () {
      const serialization = UriStringStateSerialization(
        strategy: UriStrategy.path,
      );

      test('serializes to path', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
        );

        final uri = serialization.convert(node);

        expect(uri.path.isNotEmpty, isTrue);
        expect(uri.fragment, isEmpty);
      });

      test('round trip works', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          arguments: const {'key': 'value'},
          children: [
            RouteNode.fromRoute(route: const YxRoute(id: 'child')),
          ],
        );

        final uri = serialization.convert(node);
        final parsed = serialization.parse(uri);

        expect(parsed, equals(node));
      });
    });

    group('mergeQueryParams', () {
      test('merges query params into deepest child', () {
        const serialization = UriStringStateSerialization(
          strategy: UriStrategy.path,
          mergeQueryParams: true,
        );

        // First create a valid encoded node
        final originalNode = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
        );
        final encodedUri = serialization.convert(originalNode);

        // Add query params to the URI
        final uriWithParams = encodedUri.replace(
          queryParameters: {'oauth_code': '12345'},
        );

        final node = serialization.parse(uriWithParams);

        expect(node.route.id, equals('root'));
        expect(node.arguments['oauth_code'], equals('12345'));
      });

      test('does not merge when mergeQueryParams is false', () {
        const serialization = UriStringStateSerialization(
          strategy: UriStrategy.path,
          mergeQueryParams: false,
        );

        final originalNode = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
        );
        final encodedUri = serialization.convert(originalNode);

        final uriWithParams = encodedUri.replace(
          queryParameters: {'oauth_code': '12345'},
        );

        final node = serialization.parse(uriWithParams);

        expect(node.arguments['oauth_code'], isNull);
      });
    });
  });
}
