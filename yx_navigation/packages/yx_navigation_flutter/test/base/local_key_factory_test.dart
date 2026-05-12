import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
// internal type, not exported
import 'package:yx_navigation_flutter/src/base/local_key_factory.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('LocalKeyFactory', () {
    test('produces ValueKey of route id when arguments are empty', () {
      // arrange
      const actualFactory = LocalKeyFactory();
      final actualNode = makeNode(route: makeRoute(id: 'home'));

      // act
      final actualKey = actualFactory.createKey(actualNode);

      // assert
      expect(actualKey, equals(const ValueKey<String>('home')));
    });

    test('same route+arguments produce equal LocalKeys (contract)', () {
      // arrange
      const actualFactory = LocalKeyFactory();
      final actualFirst = makeNode(
        route: makeRoute(id: 'profile'),
        arguments: const {'id': '42', 'tab': 'bio'},
      );
      final actualSecond = makeNode(
        route: makeRoute(id: 'profile'),
        arguments: const {'id': '42', 'tab': 'bio'},
      );

      // act/assert: equivalent nodes MUST produce equal keys. Nothing is
      // asserted about the underlying textual format.
      expect(
        actualFactory.createKey(actualFirst),
        equals(actualFactory.createKey(actualSecond)),
      );
    });

    test('different route ids produce distinct LocalKeys (contract)', () {
      // arrange
      const actualFactory = LocalKeyFactory();
      final actualFirst = makeNode(route: makeRoute(id: 'a'));
      final actualSecond = makeNode(route: makeRoute(id: 'b'));

      // act/assert
      expect(
        actualFactory.createKey(actualFirst),
        isNot(equals(actualFactory.createKey(actualSecond))),
      );
    });

    test('different argument sets produce distinct LocalKeys (contract)', () {
      // arrange
      const actualFactory = LocalKeyFactory();
      final actualFirst = makeNode(
        route: makeRoute(id: 'profile'),
        arguments: const {'id': '42'},
      );
      final actualSecond = makeNode(
        route: makeRoute(id: 'profile'),
        arguments: const {'id': '7'},
      );

      // act/assert
      expect(
        actualFactory.createKey(actualFirst),
        isNot(equals(actualFactory.createKey(actualSecond))),
      );
    });
  });
}
