import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/router/route_node_provider.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('RouteNodeProvider', () {
    testWidgets('routeNodeOf returns the provided node', (tester) async {
      // arrange
      final expectedNode = makeNode(route: makeRoute(id: 'home'));
      RouteNode? actualNode;

      // act
      await tester.pumpWidget(
        RouteNodeProvider(
          routeNode: expectedNode,
          child: Builder(
            builder: (context) {
              actualNode = RouteNodeProvider.routeNodeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualNode, same(expectedNode));
    });

    testWidgets('routeNodeMaybeOf returns null when provider is absent',
        (tester) async {
      // arrange
      RouteNode? actualNode;

      // act
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            actualNode = RouteNodeProvider.routeNodeMaybeOf(context);
            return const SizedBox.shrink();
          },
        ),
      );

      // assert
      expect(actualNode, isNull);
    });

    testWidgets('routeNodeOf throws when provider is absent', (tester) async {
      // arrange
      Object? caughtError;

      // act
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            try {
              RouteNodeProvider.routeNodeOf(context);
            } on Object catch (e) {
              caughtError = e;
            }
            return const SizedBox.shrink();
          },
        ),
      );

      // assert
      expect(caughtError, isA<ArgumentError>());
    });

    test('updateShouldNotify is true when routeNode changes', () {
      // arrange
      final oldNode = makeNode(route: makeRoute(id: 'a'));
      final newNode = makeNode(route: makeRoute(id: 'b'));
      final actualProvider = RouteNodeProvider(
        routeNode: newNode,
        child: const SizedBox.shrink(),
      );
      final oldProvider = RouteNodeProvider(
        routeNode: oldNode,
        child: const SizedBox.shrink(),
      );

      // assert
      expect(actualProvider.updateShouldNotify(oldProvider), isTrue);
    });

    test('updateShouldNotify is false when routeNode is unchanged', () {
      // arrange
      final node = makeNode();
      final actualProvider = RouteNodeProvider(
        routeNode: node,
        child: const SizedBox.shrink(),
      );
      final oldProvider = RouteNodeProvider(
        routeNode: node,
        child: const SizedBox.shrink(),
      );

      // assert
      expect(actualProvider.updateShouldNotify(oldProvider), isFalse);
    });
  });
}
