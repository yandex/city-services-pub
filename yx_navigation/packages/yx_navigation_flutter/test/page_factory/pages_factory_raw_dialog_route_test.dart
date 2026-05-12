import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('RawDialogRoutePageFactory', () {
    testWidgets('builds a RawDialogRoutePage with declared parameters',
        (tester) async {
      // arrange
      const expectedKey = ValueKey('raw-dialog-key');
      final expectedNode = makeNode(route: makeRoute(id: 'raw'));
      Page<String>? actualPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final sourceRoute = RawDialogRoute<String>(
                pageBuilder: (_, __, ___) => const SizedBox.shrink(),
              );
              final factory = PagesFactory<String>.rawDialog(
                route: sourceRoute,
                barrierDismissible: true,
                transitionDuration: const Duration(milliseconds: 200),
                reverseTransitionDuration: const Duration(milliseconds: 150),
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
      expect(actualPage, isA<RawDialogRoutePage<String>>());
      expect(actualPage!.key, equals(expectedKey));
      expect(
        (actualPage! as RawDialogRoutePage<String>).transitionDuration,
        equals(const Duration(milliseconds: 200)),
      );
    });

    testWidgets(
      'createRoute forwards all documented barrier parameters from Page to '
      'RawDialogRoute',
      (tester) async {
        // arrange
        const expectedBarrierColor = Color(0xAABBCCDD);
        const expectedBarrierLabel = 'raw-dialog-label';
        const expectedAnchor = Offset(5, 6);
        const expectedDuration = Duration(milliseconds: 321);

        RawDialogRoute<String>? actualRoute;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final source = RawDialogRoute<String>(
                  pageBuilder: (_, __, ___) => const SizedBox.shrink(),
                );
                final page = RawDialogRoutePage<String>(
                  route: source,
                  barrierDismissible: false,
                  transitionDuration: expectedDuration,
                  reverseTransitionDuration: const Duration(milliseconds: 99),
                  barrierColor: expectedBarrierColor,
                  barrierLabel: expectedBarrierLabel,
                  anchorPoint: expectedAnchor,
                );
                actualRoute =
                    page.createRoute(context) as RawDialogRoute<String>;
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
        expect(actualRoute!.transitionDuration, equals(expectedDuration));
      },
    );
  });
}
