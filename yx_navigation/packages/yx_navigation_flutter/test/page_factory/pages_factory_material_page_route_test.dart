import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('MaterialPageFactory', () {
    testWidgets('buildPage returns a ProxyMaterialPage with expected metadata',
        (tester) async {
      // arrange
      const expectedKey = ValueKey('material-key');
      final expectedNode = makeNode(
        route: makeRoute(id: 'home'),
        arguments: const {'x': '1'},
      );
      const factory = PagesFactory<String>.material(
        fullscreenDialog: true,
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
      expect(actualPage, isA<ProxyMaterialPage<String>>());
      expect(actualPage!.key, equals(expectedKey));
      expect(actualPage!.name, equals('home'));
      expect(
        (actualPage! as MaterialPage<String>).fullscreenDialog,
        isTrue,
      );
    });

    // The "stores completer reference" test was deleted — real pop-completion
    // behaviour is covered in page_factory_create_route_test.dart.
  });
}
