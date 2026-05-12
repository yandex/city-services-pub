import 'package:test/test.dart';
import 'package:yx_navigation/src/deeplink/deeplink_handler_strategy.dart';

import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('DeeplinkHandlerStrategy', () {
    test('FIFO iterates handlers in their registration order', () {
      // arrange
      const actualStrategy = DeeplinkHandlerStrategy.fifo();
      final handler1 = DeeplinkHandlerMock();
      final handler2 = DeeplinkHandlerMock();
      final handler3 = DeeplinkHandlerMock();

      // act
      final actual =
          actualStrategy.apply([handler1, handler2, handler3]).toList();

      // assert
      expect(actual, orderedEquals([handler1, handler2, handler3]));
    });

    test('LIFO iterates handlers in reverse registration order', () {
      // arrange
      const actualStrategy = DeeplinkHandlerStrategy.lifo();
      final handler1 = DeeplinkHandlerMock();
      final handler2 = DeeplinkHandlerMock();
      final handler3 = DeeplinkHandlerMock();

      // act
      final actual =
          actualStrategy.apply([handler1, handler2, handler3]).toList();

      // assert
      expect(actual, orderedEquals([handler3, handler2, handler1]));
    });
  });
}
