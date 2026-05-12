import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('CupertinoDialogRoutePageFactory', () {
    testWidgets(
        'builds a CupertinoDialogRoutePage with the declared parameters',
        (tester) async {
      // arrange
      const expectedKey = ValueKey('cupertino-dialog-key');
      final expectedNode = makeNode(route: makeRoute(id: 'c-dialog'));
      Page<String>? actualPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final sourceRoute = CupertinoDialogRoute<String>(
                context: context,
                builder: (_) => const SizedBox.shrink(),
              );
              final factory = PagesFactory<String>.cupertinoDialog(
                route: sourceRoute,
                barrierDismissible: true,
              );
              actualPage = factory.call(
                context,
                expectedNode,
                expectedKey,
                const SizedBox.shrink(),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualPage, isA<CupertinoDialogRoutePage<String>>());
      expect(actualPage!.key, equals(expectedKey));
      expect(actualPage!.name, equals('c-dialog'));
      expect(
        (actualPage! as CupertinoDialogRoutePage<String>).barrierDismissible,
        isTrue,
      );
    });

    testWidgets(
      'createRoute forwards all documented barrier parameters from Page to '
      'CupertinoDialogRoute',
      (tester) async {
        // arrange
        const expectedBarrierColor = Color(0xAA445566);
        const expectedBarrierLabel = 'c-dialog-label';
        const expectedAnchor = Offset(7, 8);

        CupertinoDialogRoute<String>? actualRoute;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final source = CupertinoDialogRoute<String>(
                  context: context,
                  builder: (_) => const SizedBox.shrink(),
                );
                final page = CupertinoDialogRoutePage<String>(
                  route: source,
                  barrierDismissible: false,
                  barrierColor: expectedBarrierColor,
                  barrierLabel: expectedBarrierLabel,
                  anchorPoint: expectedAnchor,
                );
                actualRoute =
                    page.createRoute(context) as CupertinoDialogRoute<String>;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // assert
        expect(actualRoute!.barrierDismissible, isFalse);
        expect(actualRoute!.barrierColor, equals(expectedBarrierColor));
        expect(actualRoute!.barrierLabel, equals(expectedBarrierLabel));
        expect(actualRoute!.anchorPoint, equals(expectedAnchor));
      },
    );
  });
}
