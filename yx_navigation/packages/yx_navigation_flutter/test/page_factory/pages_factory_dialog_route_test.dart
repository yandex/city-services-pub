import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('DialogRoutePageFactory', () {
    testWidgets('builds a DialogRoutePage with the declared parameters',
        (tester) async {
      // arrange
      const expectedKey = ValueKey('dialog-key');
      final expectedNode = makeNode(route: makeRoute(id: 'dialog'));
      Page<String>? actualPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final sourceRoute = DialogRoute<String>(
                context: context,
                builder: (_) => const SizedBox.shrink(),
              );
              final factory = PagesFactory<String>.dialog(
                route: sourceRoute,
                barrierDismissible: true,
                useSafeArea: true,
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
      expect(actualPage, isA<DialogRoutePage<String>>());
      expect(actualPage!.key, equals(expectedKey));
      expect(actualPage!.name, equals('dialog'));
      expect(
        (actualPage! as DialogRoutePage<String>).barrierDismissible,
        isTrue,
      );
      expect(
        (actualPage! as DialogRoutePage<String>).useSafeArea,
        isTrue,
      );
    });

    testWidgets(
      'createRoute forwards all documented barrier parameters from Page to '
      'DialogRoute',
      (tester) async {
        // arrange
        const expectedBarrierColor = Color(0xAA112233);
        const expectedBarrierLabel = 'dialog-label';
        const expectedAnchor = Offset(12, 34);

        DialogRoute<String>? actualRoute;

        // act
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final source = DialogRoute<String>(
                  context: context,
                  builder: (_) => const SizedBox.shrink(),
                );
                final page = DialogRoutePage<String>(
                  route: source,
                  barrierDismissible: false,
                  useSafeArea: false,
                  barrierColor: expectedBarrierColor,
                  barrierLabel: expectedBarrierLabel,
                  anchorPoint: expectedAnchor,
                );
                actualRoute = page.createRoute(context) as DialogRoute<String>;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // assert: every forwardable field is passed through unchanged.
        expect(actualRoute!.barrierDismissible, isFalse);
        expect(actualRoute!.barrierColor, equals(expectedBarrierColor));
        expect(actualRoute!.barrierLabel, equals(expectedBarrierLabel));
        expect(actualRoute!.anchorPoint, equals(expectedAnchor));
      },
    );
  });
}
