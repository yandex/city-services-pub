import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';

import '../helpers/factories.dart';

void main() {
  group('RouteNavigator', () {
    group('push method', () {
      test('adds new route node to children', () {
        // arrange
        const expectedRoute = YxRoute(id: 'push');
        final actualNavigator =
            makeStateManager(root: makeNode(route: const YxRoute(id: 'root')))
              // act
              ..push(expectedRoute);

        // assert
        expect(actualNavigator.state.children, hasLength(1));
        expect(
          actualNavigator.state.children.first.route,
          equals(expectedRoute),
        );
      });
    });

    group('pushAll method', () {
      test('adds new route nodes to children', () {
        // arrange
        const expectedFirst = YxRoute(id: 'pushAll1');
        const expectedSecond = YxRoute(id: 'pushAll2');
        final actualNavigator =
            makeStateManager(root: makeNode(route: const YxRoute(id: 'root')))
              // act
              ..pushAll([
                (route: expectedFirst, arguments: null, extra: null),
                (route: expectedSecond, arguments: null, extra: null),
              ]);

        // assert
        expect(actualNavigator.state.children, hasLength(2));
        expect(
          actualNavigator.state.children.first.route,
          equals(expectedFirst),
        );
        expect(
          actualNavigator.state.children.last.route,
          equals(expectedSecond),
        );
      });
    });

    group('pushReplacement method', () {
      test('adds new route node when children are empty', () {
        // arrange
        const expectedRoute = YxRoute(id: 'pushReplacement');
        final actualNavigator =
            makeStateManager(root: makeNode(route: const YxRoute(id: 'root')))
              // act
              ..pushReplacement(expectedRoute);

        // assert
        expect(actualNavigator.state.children, hasLength(1));
        expect(
          actualNavigator.state.children.last.route,
          equals(expectedRoute),
        );
      });

      test('replaces last route when children already contain a route', () {
        // arrange
        const expectedRoute = YxRoute(id: 'pushReplacement');
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [makeNode(route: const YxRoute(id: 'child'))],
          ),
        )
          // act
          ..pushReplacement(expectedRoute);

        // assert
        expect(actualNavigator.state.children, hasLength(1));
        expect(
          actualNavigator.state.children.last.route,
          equals(expectedRoute),
        );
      });
    });

    group('pushAndRemoveUntil method', () {
      test('adds new route and removes previous routes when predicate is false',
          () {
        // arrange
        const expectedRoute = YxRoute(id: 'pushAndRemoveUntil');
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [
              makeNode(route: const YxRoute(id: '1')),
              makeNode(route: const YxRoute(id: '2')),
            ],
          ),
        )
          // act
          ..pushAndRemoveUntil(expectedRoute, (node) => false);

        // assert
        expect(actualNavigator.state.children, hasLength(1));
        expect(
          actualNavigator.state.children.last.route,
          equals(expectedRoute),
        );
      });
    });

    group('maybePop method', () {
      test('pops the top-most route when stack has more than one child', () {
        // arrange
        const expectedFirst = YxRoute(id: 'child1');
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [
              makeNode(route: expectedFirst),
              makeNode(route: const YxRoute(id: 'child2')),
            ],
          ),
        )
          // act
          ..maybePop();

        // assert
        expect(actualNavigator.state.children, hasLength(1));
        expect(
          actualNavigator.state.children.last.route,
          equals(expectedFirst),
        );
      });

      test('does not pop when only one route is in the stack', () {
        // arrange
        const expectedFirst = YxRoute(id: 'child1');
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [makeNode(route: expectedFirst)],
          ),
        )
          // act
          ..maybePop();

        // assert
        expect(actualNavigator.state.children, hasLength(1));
        expect(
          actualNavigator.state.children.last.route,
          equals(expectedFirst),
        );
      });
    });

    group('pop method', () {
      test('pops the top-most route when two children are present', () {
        // arrange
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [
              makeNode(route: const YxRoute(id: 'child')),
              makeNode(route: const YxRoute(id: 'child')),
            ],
          ),
        )
          // act
          ..pop();

        // assert
        expect(actualNavigator.state.children, hasLength(1));
      });
    });

    group('popAll method', () {
      test('removes all routes except the first one', () {
        // arrange
        const expectedFirst = YxRoute(id: 'child1');
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [
              makeNode(route: expectedFirst),
              makeNode(route: const YxRoute(id: 'child2')),
              makeNode(route: const YxRoute(id: 'child3')),
            ],
          ),
        )
          // act
          ..popAll();

        // assert
        expect(actualNavigator.state.children, hasLength(1));
        expect(
          actualNavigator.state.children.first.route,
          equals(expectedFirst),
        );
      });
    });

    group('popUntil method', () {
      test('pops routes until predicate returns true', () {
        // arrange
        const expectedFirst = YxRoute(id: 'child1');
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [
              makeNode(route: expectedFirst),
              makeNode(route: expectedFirst),
              makeNode(route: const YxRoute(id: 'child2')),
              makeNode(route: const YxRoute(id: 'child3')),
            ],
          ),
        )
          // act
          ..popUntil((node) => node.route == expectedFirst);

        // assert
        expect(actualNavigator.state.children, hasLength(2));
        expect(
          actualNavigator.state.children.first.route,
          equals(expectedFirst),
        );
        expect(
          actualNavigator.state.children.last.route,
          equals(expectedFirst),
        );
      });

      test('pops all routes except the first when predicate never returns true',
          () {
        // arrange
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [
              makeNode(route: const YxRoute(id: '1')),
              makeNode(route: const YxRoute(id: 'child1')),
              makeNode(route: const YxRoute(id: 'child2')),
            ],
          ),
        )
          // act
          ..popUntil((node) => false);

        // assert
        expect(actualNavigator.state.children, hasLength(1));
      });

      test('pops routes until predicate matches node arguments', () {
        // arrange
        final expectedArguments = {'test': 'test'};
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [
              makeNode(route: const YxRoute(id: 'child1')),
              makeNode(
                route: const YxRoute(id: 'child2'),
                arguments: expectedArguments,
              ),
              makeNode(route: const YxRoute(id: 'child3')),
              makeNode(route: const YxRoute(id: 'child4')),
            ],
          ),
        )
          // act
          ..popUntil(
            (node) => const DeepCollectionEquality().equals(
              node.arguments,
              expectedArguments,
            ),
          );

        // assert
        expect(actualNavigator.state.children, hasLength(2));
        expect(
          actualNavigator.state.children.last.arguments,
          equals(expectedArguments),
        );
      });
    });

    group('popWhere method', () {
      test('pops routes where predicate is true', () {
        // arrange
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [
              makeNode(route: const YxRoute(id: 'child1')),
              makeNode(route: const YxRoute(id: 'child2')),
            ],
          ),
        )
          // act
          ..popWhere((node) => node.route.id == 'child1');

        // assert
        expect(actualNavigator.state.children, hasLength(1));
        expect(actualNavigator.state.children.last.route.id, equals('child2'));
      });

      test('pops all routes except the first when predicate matches every node',
          () {
        // arrange
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [
              makeNode(route: const YxRoute(id: 'child1')),
              makeNode(route: const YxRoute(id: 'child2')),
            ],
          ),
        )
          // act
          ..popWhere((node) => true);

        // assert
        expect(actualNavigator.state.children, hasLength(1));
      });

      test('pops first and last when predicate matches both', () {
        // arrange
        final actualNavigator = makeStateManager(
          root: makeNode(
            route: const YxRoute(id: 'root'),
            children: [
              makeNode(route: const YxRoute(id: 'first')),
              makeNode(route: const YxRoute(id: 'middle')),
              makeNode(route: const YxRoute(id: 'last')),
            ],
          ),
        )
          // act
          ..popWhere(
            (node) => node.route.id == 'first' || node.route.id == 'last',
          );

        // assert
        expect(actualNavigator.state.children, hasLength(1));
        expect(actualNavigator.state.children.last.route.id, equals('middle'));
      });
    });
  });
}
