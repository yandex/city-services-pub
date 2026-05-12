import 'package:test/test.dart';
import 'package:yx_navigation/src/base/comparators/route_node_comparator.dart';

import '../../helpers/factories.dart';
import '../../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('RouteNodeComparator', () {
    group('compareByRoute method', () {
      test('returns zero when both nodes share the same route', () {
        // arrange
        final actualFirst = makeNode(route: makeRoute(id: 'a'));
        final actualSecond = makeNode(route: makeRoute(id: 'a'));

        // act
        final actual = RouteNodeComparator.compareByRoute(
          actualFirst,
          actualSecond,
        );

        // assert
        expect(actual, equals(0));
      });

      test(
          'returns a negative value when the first route id is lexicographically smaller',
          () {
        // arrange
        final actualFirst = makeNode(route: makeRoute(id: 'a'));
        final actualSecond = makeNode(route: makeRoute(id: 'b'));

        // act
        final actual = RouteNodeComparator.compareByRoute(
          actualFirst,
          actualSecond,
        );

        // assert
        expect(actual, lessThan(0));
      });

      test(
          'returns a positive value when the first route id is lexicographically larger',
          () {
        // arrange
        final actualFirst = makeNode(route: makeRoute(id: 'z'));
        final actualSecond = makeNode(route: makeRoute(id: 'a'));

        // act
        final actual = RouteNodeComparator.compareByRoute(
          actualFirst,
          actualSecond,
        );

        // assert
        expect(actual, greaterThan(0));
      });
    });
  });
}
