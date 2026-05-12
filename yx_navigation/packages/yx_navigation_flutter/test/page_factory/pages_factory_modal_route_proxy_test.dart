import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('ModalRouteProxyPageFactory', () {
    testWidgets(
        'builds a ModalRouteProxyPage with node-derived name when not overridden',
        (tester) async {
      // arrange
      const expectedKey = ValueKey('modal-key');
      final expectedNode = makeNode(route: makeRoute(id: 'modal'));
      final sourceRoute = MaterialPageRoute<String>(
        builder: (_) => const SizedBox.shrink(),
      );
      final factory = PagesFactory<String>.modalRouteProxy(
        route: sourceRoute,
      );

      Page<String>? actualPage;

      // act
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            actualPage = factory.call(
              context,
              expectedNode,
              expectedKey,
              const SizedBox.shrink(),
            );
            return const SizedBox.shrink();
          },
        ),
      );

      // assert
      expect(actualPage, isA<ModalRouteProxyPage<String>>());
      expect(actualPage!.key, equals(expectedKey));
      expect(actualPage!.name, equals('modal'));
    });

    testWidgets('allows overriding name and arguments via factory',
        (tester) async {
      // arrange
      const expectedKey = ValueKey('modal-key');
      final expectedNode = makeNode(route: makeRoute(id: 'ignored'));
      final sourceRoute = MaterialPageRoute<String>(
        builder: (_) => const SizedBox.shrink(),
      );
      final factory = PagesFactory<String>.modalRouteProxy(
        route: sourceRoute,
        name: 'override-name',
        arguments: const {'k': 'v'},
      );

      Page<String>? actualPage;

      // act
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            actualPage = factory.call(
              context,
              expectedNode,
              expectedKey,
              const SizedBox.shrink(),
            );
            return const SizedBox.shrink();
          },
        ),
      );

      // assert
      expect(actualPage!.name, equals('override-name'));
      expect(actualPage!.arguments, equals(const {'k': 'v'}));
    });
  });
}
