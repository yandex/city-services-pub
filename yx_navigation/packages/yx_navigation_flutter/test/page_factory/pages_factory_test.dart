import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('CustomPageFactory', () {
    testWidgets('delegates page construction to the custom builder',
        (tester) async {
      // arrange
      const expectedKey = ValueKey<String>('custom');
      final expectedNode = makeNode();
      final factory = PagesFactory<Object?>.custom(
        builder: (context, node, key, child) =>
            MaterialPage<Object?>(key: key, child: child),
      );
      Page<Object?>? actualPage;

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
      expect(actualPage, isA<MaterialPage<Object?>>());
      expect(actualPage!.key, equals(expectedKey));
    });
  });
}
