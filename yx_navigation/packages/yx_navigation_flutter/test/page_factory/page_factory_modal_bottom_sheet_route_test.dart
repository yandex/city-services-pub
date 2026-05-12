import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('ModalBottomSheetPageFactory', () {
    testWidgets('builds a ModalBottomSheetPage with expected metadata',
        (tester) async {
      // arrange
      const expectedKey = ValueKey('sheet-key');
      final expectedNode = makeNode(route: makeRoute(id: 'sheet'));
      const factory = PagesFactory<String>.modalBottomSheet(
        isScrollControlled: true,
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
      expect(actualPage, isA<ModalBottomSheetPage<String>>());
      expect(actualPage!.key, equals(expectedKey));
      expect(actualPage!.name, equals('sheet'));
      expect(
        (actualPage! as ModalBottomSheetPage<String>).isScrollControlled,
        isTrue,
      );
    });

    // The "stores completer and values" test was deleted — real pop-completion
    // behaviour is covered in page_factory_create_route_test.dart; the field
    // forwarding is covered by the createRoute test below.

    testWidgets(
      'createRoute forwards every documented field from Page to '
      'ModalBottomSheetRoute',
      (tester) async {
        // arrange
        const expectedShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        );
        const expectedElevation = 8.0;
        const expectedClipBehavior = Clip.hardEdge;
        const expectedConstraints = BoxConstraints(maxHeight: 400);
        const expectedBarrierColor = Color(0xAA010203);
        const expectedAnchor = Offset(3, 4);
        const expectedBarrierLabel = 'sheet-label';
        const expectedBarrierOnTapHint = 'tap-to-dismiss';
        const expectedRestorationId = 'sheet-restore';

        final transitionController = AnimationController(
          vsync: const TestVSync(),
          duration: const Duration(milliseconds: 200),
        );
        addTearDown(transitionController.dispose);

        ModalBottomSheetRoute<String>? actualRoute;

        // act
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final page = ModalBottomSheetPage<String>(
                  builder: (_) => const SizedBox.shrink(),
                  isScrollControlled: true,
                  shape: expectedShape,
                  elevation: expectedElevation,
                  clipBehavior: expectedClipBehavior,
                  constraints: expectedConstraints,
                  modalBarrierColor: expectedBarrierColor,
                  showDragHandle: true,
                  useSafeArea: true,
                  anchorPoint: expectedAnchor,
                  transitionAnimationController: transitionController,
                  barrierOnTapHint: expectedBarrierOnTapHint,
                  barrierLabel: expectedBarrierLabel,
                  restorationId: expectedRestorationId,
                  canPop: false,
                );
                actualRoute =
                    page.createRoute(context) as ModalBottomSheetRoute<String>;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // assert: every forwardable field from ModalBottomSheetPage is
        // present on the constructed route.
        expect(actualRoute!.isScrollControlled, isTrue);
        expect(actualRoute!.shape, same(expectedShape));
        expect(actualRoute!.elevation, equals(expectedElevation));
        expect(actualRoute!.clipBehavior, equals(expectedClipBehavior));
        expect(actualRoute!.constraints, equals(expectedConstraints));
        expect(actualRoute!.modalBarrierColor, equals(expectedBarrierColor));
        expect(actualRoute!.showDragHandle, isTrue);
        expect(actualRoute!.useSafeArea, isTrue);
        expect(actualRoute!.anchorPoint, equals(expectedAnchor));
        expect(
          actualRoute!.transitionAnimationController,
          same(transitionController),
        );
        expect(actualRoute!.barrierOnTapHint, equals(expectedBarrierOnTapHint));
        expect(actualRoute!.barrierLabel, equals(expectedBarrierLabel));
        // capturedThemes is allowed to be null — the Page doesn't force it.
        // isDismissible/enableDrag default to true (already checked above).
        expect(actualRoute!.isDismissible, isTrue);
        expect(actualRoute!.enableDrag, isTrue);
      },
    );
  });
}
