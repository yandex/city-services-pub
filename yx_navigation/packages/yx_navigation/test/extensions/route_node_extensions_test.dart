import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
// internal type, not exported
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/extensions/route_node_extensions.dart';

import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('RouteExtension', () {
    const actualRoute = YxRoute(id: 'ext');

    group('toNode method', () {
      test('returns an immutable node with defaults', () {
        // act
        final actual = actualRoute.toNode();

        // assert
        expect(actual.route, equals(actualRoute));
        expect(actual.children, isEmpty);
        expect(actual.arguments, isEmpty);
        expect(actual.extra, isEmpty);
      });
    });

    group('toMutableNode method', () {
      test('returns a mutable node with defaults', () {
        // act
        final actual = actualRoute.toMutableNode();

        // assert
        expect(actual, isA<MutableRouteNode>());
        expect(actual.route, equals(actualRoute));
        expect(actual.children, isEmpty);
      });
    });

    group('toImmutableNode method', () {
      test('returns an immutable node with defaults', () {
        // act
        final actual = actualRoute.toImmutableNode();

        // assert
        expect(actual, isA<ImmutableRouteNode>());
        expect(actual.route, equals(actualRoute));
      });
    });
  });
}
