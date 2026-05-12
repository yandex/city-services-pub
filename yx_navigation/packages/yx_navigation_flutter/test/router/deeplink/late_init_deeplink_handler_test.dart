import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/router/deeplink/late_init_deeplink_handler.dart';

import '../../helpers/fallbacks.dart';
import '../../helpers/mocks.dart';

void main() {
  late Uri testUri;
  late RouteNode testState;

  setUpAll(registerFallbacks);

  setUp(() {
    testUri = Uri.parse('https://example.com/test');
    testState = const YxRoute(id: 'test').toMutableNode();
  });

  group('LateInitDeeplinkHandlerImpl', () {
    group('attach method', () {
      test('attaches handler under given name', () {
        // arrange
        final handler = DeeplinkHandlerMock();
        final actualLateInit = LateInitDeeplinkHandlerImpl()
          ..attach('test', handler);

        // assert
        expect(actualLateInit.handlers, contains(handler));
      });

      test('throws StateError when name is already attached', () {
        // arrange
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        final actualLateInit = LateInitDeeplinkHandlerImpl()
          ..attach('test', handler1);

        // assert
        expect(
          () => actualLateInit.attach('test', handler2),
          throwsStateError,
        );
      });

      test('stores multiple handlers under different names', () {
        // arrange
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        final actualLateInit = LateInitDeeplinkHandlerImpl()
          ..attach('test1', handler1)
          ..attach('test2', handler2);

        // assert
        expect(actualLateInit.handlers, hasLength(2));
        expect(actualLateInit.handlers, contains(handler1));
        expect(actualLateInit.handlers, contains(handler2));
      });
    });

    group('detach method', () {
      test('removes handler by name', () {
        // arrange
        final handler = DeeplinkHandlerMock();
        final actualLateInit = LateInitDeeplinkHandlerImpl()
          ..attach('test', handler)
          ..detach('test');

        // assert
        expect(actualLateInit.handlers, isNot(contains(handler)));
      });

      test('throws StateError when name is not attached', () {
        // arrange
        final actualLateInit = LateInitDeeplinkHandlerImpl();

        // assert
        expect(
          () => actualLateInit.detach('nonexistent'),
          throwsStateError,
        );
      });
    });

    group('caching', () {
      test('invalidates cache on attach', () {
        // arrange
        final handler = DeeplinkHandlerMock();
        final actualLateInit = LateInitDeeplinkHandlerImpl();
        final handlersBefore = actualLateInit.handlers;
        expect(handlersBefore, isEmpty);

        // act
        actualLateInit.attach('test', handler);

        // assert
        final handlersAfter = actualLateInit.handlers;
        expect(handlersAfter, contains(handler));
      });

      test('invalidates cache on detach', () {
        // arrange
        final handler = DeeplinkHandlerMock();
        final actualLateInit = LateInitDeeplinkHandlerImpl()
          ..attach('test', handler);
        final handlersBefore = actualLateInit.handlers;
        expect(handlersBefore, contains(handler));

        // act
        actualLateInit.detach('test');

        // assert
        final handlersAfter = actualLateInit.handlers;
        expect(handlersAfter, isNot(contains(handler)));
      });

      test('returns the same instance when cache is valid', () {
        // arrange
        final handler = DeeplinkHandlerMock();
        final actualLateInit = LateInitDeeplinkHandlerImpl()
          ..attach('test', handler);

        // act
        final handlers1 = actualLateInit.handlers;
        final handlers2 = actualLateInit.handlers;

        // assert
        expect(identical(handlers1, handlers2), isTrue);
      });
    });

    group('handlers combination', () {
      test('exposes both base and attached handlers', () {
        // arrange
        final baseHandler = DeeplinkHandlerMock();
        final attachedHandler = DeeplinkHandlerMock();

        // act
        final actualLateInit = LateInitDeeplinkHandlerImpl(
          handlers: [baseHandler],
        )..attach('attached', attachedHandler);

        // assert
        expect(actualLateInit.handlers, hasLength(2));
        expect(actualLateInit.handlers, contains(baseHandler));
        expect(actualLateInit.handlers, contains(attachedHandler));
      });

      test('runs base handlers before attached when FIFO is used', () {
        // arrange
        final baseHandler = DeeplinkHandlerMock();
        final attachedHandler = DeeplinkHandlerMock();
        when(() => baseHandler.handle(any(), any()))
            .thenReturn(const DeeplinkHandlerResult.handled());
        final actualLateInit = LateInitDeeplinkHandlerImpl(
          handlers: [baseHandler],
        )..attach('attached', attachedHandler);

        // act
        final actual = actualLateInit.handle(testUri, testState);

        // assert
        expect(actual, isA<DeeplinkHandlerHandledResult>());
        verify(() => baseHandler.handle(testUri, testState)).called(1);
        verifyNever(() => attachedHandler.handle(any(), any()));
      });

      test('runs attached handlers first when LIFO is used', () {
        // arrange
        final baseHandler = DeeplinkHandlerMock();
        final attachedHandler = DeeplinkHandlerMock();
        when(() => attachedHandler.handle(any(), any()))
            .thenReturn(const DeeplinkHandlerResult.handled());
        final actualLateInit = LateInitDeeplinkHandlerImpl(
          strategy: const DeeplinkHandlerStrategy.lifo(),
          handlers: [baseHandler],
        )..attach('attached', attachedHandler);

        // act
        final actual = actualLateInit.handle(testUri, testState);

        // assert
        expect(actual, isA<DeeplinkHandlerHandledResult>());
        verifyNever(() => baseHandler.handle(any(), any()));
        verify(() => attachedHandler.handle(testUri, testState)).called(1);
      });
    });

    group('strategy', () {
      test('FIFO iterates handlers from start to end', () {
        // arrange
        final actualCallOrder = <int>[];
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        final handler3 = DeeplinkHandlerMock();
        when(() => handler1.handle(any(), any())).thenAnswer((_) {
          actualCallOrder.add(1);
          return null;
        });
        when(() => handler2.handle(any(), any())).thenAnswer((_) {
          actualCallOrder.add(2);
          return null;
        });
        when(() => handler3.handle(any(), any())).thenAnswer((_) {
          actualCallOrder.add(3);
          return null;
        });

        // act
        LateInitDeeplinkHandlerImpl(handlers: [handler1])
          ..attach('h2', handler2)
          ..attach('h3', handler3)
          ..handle(testUri, testState);

        // assert
        expect(actualCallOrder, equals([1, 2, 3]));
      });

      test('LIFO iterates handlers from end to start', () {
        // arrange
        final actualCallOrder = <int>[];
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        final handler3 = DeeplinkHandlerMock();
        when(() => handler1.handle(any(), any())).thenAnswer((_) {
          actualCallOrder.add(1);
          return null;
        });
        when(() => handler2.handle(any(), any())).thenAnswer((_) {
          actualCallOrder.add(2);
          return null;
        });
        when(() => handler3.handle(any(), any())).thenAnswer((_) {
          actualCallOrder.add(3);
          return null;
        });

        // act
        LateInitDeeplinkHandlerImpl(
          strategy: const DeeplinkHandlerStrategy.lifo(),
          handlers: [handler1],
        )
          ..attach('h2', handler2)
          ..attach('h3', handler3)
          ..handle(testUri, testState);

        // assert
        expect(actualCallOrder, equals([3, 2, 1]));
      });
    });
  });
}
