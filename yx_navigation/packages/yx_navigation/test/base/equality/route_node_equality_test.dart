import 'package:test/test.dart';
import 'package:yx_navigation/src/base/equality/route_node_equality.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';

void main() {
  late YxRoute route1;
  late YxRoute route2;
  late RouteNode routeNode1;
  late RouteNode routeNode2;
  late RouteNode routeNode3;
  late RouteNode routeNode4;
  late RouteNode routeNode5;
  late RouteNode routeNode6;

  setUp(() {
    route1 = const YxRoute(id: 'route1');
    route2 = const YxRoute(id: 'route2');

    routeNode1 = RouteNode.fromRoute(
      route: route1,
      arguments: const {'arg1': 'value1'},
    );
    routeNode2 = RouteNode.fromRoute(
      route: route2,
      arguments: const {'arg2': 'value2'},
    );
    routeNode3 = RouteNode.fromRoute(
      route: route1,
      arguments: const {'arg3': 'value3'},
    );
    routeNode4 = RouteNode.fromRoute(
      route: route1,
      arguments: const {'arg1': 'value1'},
    );
    routeNode5 = RouteNode.fromRoute(
      route: route1,
      arguments: const {'arg1': 'value1'},
      extra: const {'extra1': 'value1'},
    );
    routeNode6 = RouteNode.fromRoute(
      route: route1,
      arguments: const {'arg1': 'value1'},
      extra: const {'extra2': 'value2'},
    );
  });

  group('RouteNodeEquality', () {
    group('ByRouteEquality', () {
      const equality = ByRouteEquality();

      test('returns false when routes differ', () {
        // act
        final actual = equality.equals(routeNode1, routeNode2);

        // assert
        expect(actual, isFalse);
      });

      test('returns true when routes are equal', () {
        // act
        final actual = equality.equals(routeNode1, routeNode1);

        // assert
        expect(actual, isTrue);
      });
    });

    group('RouteAndArgumentsEquality', () {
      const equality = RouteAndArgumentsEquality();

      test('returns false when routes differ', () {
        // act
        final actual = equality.equals(routeNode1, routeNode2);

        // assert
        expect(actual, isFalse);
      });

      test('returns false when arguments differ', () {
        // act
        final actual = equality.equals(routeNode1, routeNode3);

        // assert
        expect(actual, isFalse);
      });

      test('returns true when route and arguments match', () {
        // act
        final actual = equality.equals(routeNode1, routeNode4);

        // assert
        expect(actual, isTrue);
      });
    });

    group('DeepRouteNodeEquality', () {
      const equality = DeepRouteNodeEquality();

      test('returns false when routes differ', () {
        // act
        final actual = equality.equals(routeNode1, routeNode2);

        // assert
        expect(actual, isFalse);
      });

      test('returns false when arguments differ', () {
        // act
        final actual = equality.equals(routeNode1, routeNode3);

        // assert
        expect(actual, isFalse);
      });

      test('returns true when route and arguments match', () {
        // act
        final actual = equality.equals(routeNode1, routeNode4);

        // assert
        expect(actual, isTrue);
      });

      test('returns false when extra differs', () {
        // act
        final actual = equality.equals(routeNode5, routeNode6);

        // assert
        expect(actual, isFalse);
      });
    });
  });
}
