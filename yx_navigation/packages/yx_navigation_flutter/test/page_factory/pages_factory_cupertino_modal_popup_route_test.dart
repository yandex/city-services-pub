import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('CupertinoModalPopupRoutePageFactory', () {
    testWidgets(
        'builds a CupertinoModalPopupRoutePage with declared parameters',
        (tester) async {
      // arrange
      const expectedKey = ValueKey('popup-key');
      final expectedNode = makeNode(route: makeRoute(id: 'popup'));
      Page<String>? actualPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final sourceRoute = CupertinoModalPopupRoute<String>(
                builder: (_) => const SizedBox.shrink(),
              );
              final factory = PagesFactory<String>.cupertinoModalPopup(
                route: sourceRoute,
                barrierDismissible: true,
                semanticsDismissible: false,
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
      expect(actualPage, isA<CupertinoModalPopupRoutePage<String>>());
      expect(actualPage!.key, equals(expectedKey));
      expect(
        (actualPage! as CupertinoModalPopupRoutePage<String>)
            .semanticsDismissible,
        isFalse,
      );
    });

    testWidgets(
      'createRoute forwards all documented barrier parameters from Page to '
      'CupertinoModalPopupRoute',
      (tester) async {
        // arrange
        const expectedBarrierColor = Color(0xAA778899);
        const expectedBarrierLabel = 'popup-label';
        const expectedAnchor = Offset(1, 2);

        CupertinoModalPopupRoute<String>? actualRoute;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final source = CupertinoModalPopupRoute<String>(
                  builder: (_) => const SizedBox.shrink(),
                );
                final page = CupertinoModalPopupRoutePage<String>(
                  route: source,
                  barrierDismissible: false,
                  semanticsDismissible: true,
                  barrierColor: expectedBarrierColor,
                  barrierLabel: expectedBarrierLabel,
                  anchorPoint: expectedAnchor,
                );
                actualRoute = page.createRoute(context)
                    as CupertinoModalPopupRoute<String>;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // assert
        expect(actualRoute!.barrierDismissible, isFalse);
        expect(actualRoute!.barrierColor, equals(expectedBarrierColor));
        expect(actualRoute!.barrierLabel, equals(expectedBarrierLabel));
        expect(actualRoute!.semanticsDismissible, isTrue);
        expect(actualRoute!.anchorPoint, equals(expectedAnchor));
      },
    );
  });
}
