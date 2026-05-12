import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';

import '../helpers/factories.dart';

void main() {
  group('RouteNode', () {
    group('operator ==', () {
      test('returns true for equal immutable nodes', () {
        // arrange
        final firstNode = makeImmutableNode(route: const YxRoute(id: 'first'));
        final secondNode = makeImmutableNode(route: const YxRoute(id: 'first'));

        // assert
        expect(firstNode, equals(secondNode));
      });

      test('returns true for equal mutable nodes', () {
        // arrange
        final firstNode = makeMutableNode(route: const YxRoute(id: 'first'));
        final secondNode = makeMutableNode(route: const YxRoute(id: 'first'));

        // assert
        expect(firstNode, equals(secondNode));
      });

      test('returns false when immutable nodes have different routes', () {
        // arrange
        final firstNode = makeImmutableNode(route: const YxRoute(id: 'first'));
        final secondNode =
            makeImmutableNode(route: const YxRoute(id: 'second'));

        // assert
        expect(firstNode, isNot(equals(secondNode)));
      });

      test('returns false when comparing immutable to mutable', () {
        // arrange
        final firstNode = makeImmutableNode(route: const YxRoute(id: 'first'));
        final secondNode = makeMutableNode(route: const YxRoute(id: 'first'));

        // assert
        expect(firstNode, isNot(equals(secondNode)));
      });
    });

    group('equalsBy method', () {
      test('returns true for equal immutable nodes', () {
        // arrange
        final firstNode = makeImmutableNode(route: const YxRoute(id: 'first'));
        final secondNode = makeImmutableNode(route: const YxRoute(id: 'first'));

        // assert
        expect(firstNode.equalsBy(secondNode), isTrue);
      });

      test('returns true for equal mutable nodes', () {
        // arrange
        final firstNode = makeMutableNode(route: const YxRoute(id: 'first'));
        final secondNode = makeMutableNode(route: const YxRoute(id: 'first'));

        // assert
        expect(firstNode.equalsBy(secondNode), isTrue);
      });

      test('returns false when mutable nodes have different routes', () {
        // arrange
        final firstNode = makeMutableNode(route: const YxRoute(id: 'first'));
        final secondNode = makeMutableNode(route: const YxRoute(id: 'seconds'));

        // assert
        expect(firstNode.equalsBy(secondNode), isFalse);
      });

      test('returns false when immutable node has children and other has not',
          () {
        // arrange
        final firstNode = makeImmutableNode(
          route: const YxRoute(id: 'first'),
          children: [makeImmutableNode(route: const YxRoute(id: 'child'))],
        );
        final secondNode = makeImmutableNode(route: const YxRoute(id: 'first'));

        // assert
        expect(firstNode.equalsBy(secondNode), isFalse);
      });

      test('returns true when immutable and mutable have same shape', () {
        // arrange
        final firstNode = makeImmutableNode(route: const YxRoute(id: 'first'));
        final secondNode = makeMutableNode(route: const YxRoute(id: 'first'));

        // assert
        expect(firstNode.equalsBy(secondNode), isTrue);
      });

      test('returns true when immutable and mutable share children', () {
        // arrange
        final firstNode = makeImmutableNode(
          route: const YxRoute(id: 'first'),
          children: [makeImmutableNode(route: const YxRoute(id: 'child'))],
        );
        final secondNode = makeMutableNode(
          route: const YxRoute(id: 'first'),
          children: [makeMutableNode(route: const YxRoute(id: 'child'))],
        );

        // assert
        expect(firstNode.equalsBy(secondNode), isTrue);
      });

      test(
          'returns false when children ids differ between immutable and mutable',
          () {
        // arrange
        final firstNode = makeImmutableNode(
          route: const YxRoute(id: 'first'),
          children: [makeImmutableNode(route: const YxRoute(id: 'child'))],
        );
        final secondNode = makeMutableNode(
          route: const YxRoute(id: 'first'),
          children: [makeMutableNode(route: const YxRoute(id: 'child2'))],
        );

        // assert
        expect(firstNode.equalsBy(secondNode), isFalse);
      });
    });
  });
}
