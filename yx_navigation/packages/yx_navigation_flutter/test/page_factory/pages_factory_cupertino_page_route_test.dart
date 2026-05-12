import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('CupertinoPageFactory', () {
    testWidgets('buildPage returns a ProxyCupertinoPage with the provided key',
        (tester) async {
      // arrange
      const expectedKey = ValueKey('cupertino-key');
      final expectedNode = makeNode(route: makeRoute(id: 'c'));
      const factory = PagesFactory<String>.cupertino(title: 'Title');

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
      expect(actualPage, isA<ProxyCupertinoPage<String>>());
      expect(actualPage!.key, equals(expectedKey));
      expect(
        (actualPage! as CupertinoPage<String>).title,
        equals('Title'),
      );
    });

    // The "stores completer" test was deleted — real pop-completion behaviour
    // is covered in page_factory_create_route_test.dart.
  });
}
