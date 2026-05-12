import 'package:test/test.dart';
import 'package:yx_navigation/src/state/base/mutation.dart';

import '../../helpers/factories.dart';
import '../../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('Mutation', () {
    group('operator ==', () {
      test('returns true when both states are equal', () {
        // arrange
        final actualOriginal = makeNode(route: makeRoute(id: 'a'));
        final actualTarget = makeNode(route: makeRoute(id: 'b'));
        final actualFirst = Mutation(
          originalState: actualOriginal,
          targetState: actualTarget,
        );
        final actualSecond = Mutation(
          originalState: actualOriginal,
          targetState: actualTarget,
        );

        // assert
        expect(actualFirst, equals(actualSecond));
        expect(actualFirst.hashCode, equals(actualSecond.hashCode));
      });

      test('returns false when original states differ', () {
        // arrange
        final actualFirst = Mutation(
          originalState: makeNode(route: makeRoute(id: 'a')),
          targetState: makeNode(route: makeRoute(id: 'b')),
        );
        final actualSecond = Mutation(
          originalState: makeNode(route: makeRoute(id: 'x')),
          targetState: makeNode(route: makeRoute(id: 'b')),
        );

        // assert
        expect(actualFirst, isNot(equals(actualSecond)));
      });

      test('returns false when target states differ', () {
        // arrange
        final actualFirst = Mutation(
          originalState: makeNode(route: makeRoute(id: 'a')),
          targetState: makeNode(route: makeRoute(id: 'b')),
        );
        final actualSecond = Mutation(
          originalState: makeNode(route: makeRoute(id: 'a')),
          targetState: makeNode(route: makeRoute(id: 'c')),
        );

        // assert
        expect(actualFirst, isNot(equals(actualSecond)));
      });
    });
  });
}
