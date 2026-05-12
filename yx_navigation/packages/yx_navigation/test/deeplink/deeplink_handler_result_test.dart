import 'package:test/test.dart';
import 'package:yx_navigation/src/deeplink/deeplink_handler_result.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('DeeplinkHandlerResult', () {
    test('navigate factory exposes the target node', () {
      // arrange
      final actualNode = makeNode(route: makeRoute(id: 'target'));

      // act
      final actualResult = DeeplinkHandlerResult.navigate(actualNode);

      // assert
      expect(actualResult, isA<DeeplinkHandlerNavigateResult>());
      expect(
        (actualResult as DeeplinkHandlerNavigateResult).node,
        equals(actualNode),
      );
    });

    test('handled factory returns a DeeplinkHandlerHandledResult', () {
      // act
      const actualResult = DeeplinkHandlerResult.handled();

      // assert
      expect(actualResult, isA<DeeplinkHandlerHandledResult>());
    });

    test('sealed type supports switch exhaustiveness', () {
      // arrange
      final actualNode = makeNode(route: makeRoute(id: 'target'));
      final actualResults = <DeeplinkHandlerResult>[
        DeeplinkHandlerResult.navigate(actualNode),
        const DeeplinkHandlerResult.handled(),
      ];
      final actualTags = <String>[];

      // act
      for (final result in actualResults) {
        final tag = switch (result) {
          DeeplinkHandlerNavigateResult() => 'navigate',
          DeeplinkHandlerHandledResult() => 'handled',
        };
        actualTags.add(tag);
      }

      // assert
      expect(actualTags, orderedEquals(<String>['navigate', 'handled']));
    });
  });
}
