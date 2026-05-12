import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../../helpers/mocks.dart';

void main() {
  group('DeeplinkHandlerStrategy', () {
    group('apply method', () {
      test('FIFO returns handlers in registration order', () {
        // arrange
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        final handler3 = DeeplinkHandlerMock();
        final handlers = [handler1, handler2, handler3];
        const strategy = DeeplinkHandlerStrategy.fifo();

        // act
        final actual = strategy.apply(handlers).toList();

        // assert
        expect(actual, equals([handler1, handler2, handler3]));
      });

      test('LIFO returns handlers in reverse registration order', () {
        // arrange
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        final handler3 = DeeplinkHandlerMock();
        final handlers = [handler1, handler2, handler3];
        const strategy = DeeplinkHandlerStrategy.lifo();

        // act
        final actual = strategy.apply(handlers).toList();

        // assert
        expect(actual, equals([handler3, handler2, handler1]));
      });

      test('FIFO on empty list returns empty iterable', () {
        // arrange
        const strategy = DeeplinkHandlerStrategy.fifo();

        // assert
        expect(strategy.apply([]).toList(), isEmpty);
      });

      test('LIFO on empty list returns empty iterable', () {
        // arrange
        const strategy = DeeplinkHandlerStrategy.lifo();

        // assert
        expect(strategy.apply([]).toList(), isEmpty);
      });

      test('FIFO on single handler returns the same handler', () {
        // arrange
        final handler = DeeplinkHandlerMock();
        const strategy = DeeplinkHandlerStrategy.fifo();

        // assert
        expect(strategy.apply([handler]).single, equals(handler));
      });

      test('LIFO on single handler returns the same handler', () {
        // arrange
        final handler = DeeplinkHandlerMock();
        const strategy = DeeplinkHandlerStrategy.lifo();

        // assert
        expect(strategy.apply([handler]).single, equals(handler));
      });
    });
  });
}
