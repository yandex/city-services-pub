import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/deeplink/composite_deeplink_handler.dart';
import 'package:yx_navigation/src/deeplink/deeplink_handler_result.dart';
import 'package:yx_navigation/src/deeplink/deeplink_handler_strategy.dart';
import 'package:yx_navigation/src/extensions/route_node_extensions.dart';

import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  late Uri testUri;
  late RouteNode testState;

  setUp(() {
    testUri = Uri.parse('https://example.com/test');
    testState = const YxRoute(id: 'test').toMutableNode();
  });

  group('CompositeDeeplinkHandler', () {
    group('FIFO strategy', () {
      test('stops after the first handler returns a non-null result', () {
        // arrange
        final expectedResult = DeeplinkHandlerResult.navigate(testState);
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        when(() => handler1.handle(any(), any())).thenReturn(expectedResult);
        final actualComposite = CompositeDeeplinkHandler()
          ..add(handler1)
          ..add(handler2);

        // act
        final actual = actualComposite.handle(testUri, testState);

        // assert
        expect(actual, equals(expectedResult));
        verify(() => handler1.handle(testUri, testState)).called(1);
        verifyNever(() => handler2.handle(any(), any()));
      });

      test('falls through to the second handler when the first returns null',
          () {
        // arrange
        final expectedResult = DeeplinkHandlerResult.navigate(testState);
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        when(() => handler1.handle(any(), any())).thenReturn(null);
        when(() => handler2.handle(any(), any())).thenReturn(expectedResult);
        final actualComposite = CompositeDeeplinkHandler()
          ..add(handler1)
          ..add(handler2);

        // act
        final actual = actualComposite.handle(testUri, testState);

        // assert
        expect(actual, equals(expectedResult));
        verify(() => handler1.handle(testUri, testState)).called(1);
        verify(() => handler2.handle(testUri, testState)).called(1);
      });

      test('returns null when every handler returns null', () {
        // arrange
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        when(() => handler1.handle(any(), any())).thenReturn(null);
        when(() => handler2.handle(any(), any())).thenReturn(null);
        final actualComposite = CompositeDeeplinkHandler()
          ..add(handler1)
          ..add(handler2);

        // act
        final actual = actualComposite.handle(testUri, testState);

        // assert
        expect(actual, isNull);
        verify(() => handler1.handle(testUri, testState)).called(1);
        verify(() => handler2.handle(testUri, testState)).called(1);
      });
    });

    group('LIFO strategy', () {
      test('stops after the last handler returns a non-null result', () {
        // arrange
        final expectedResult = DeeplinkHandlerResult.navigate(testState);
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        when(() => handler2.handle(any(), any())).thenReturn(expectedResult);
        final actualComposite = CompositeDeeplinkHandler(
          strategy: const DeeplinkHandlerStrategy.lifo(),
        )
          ..add(handler1)
          ..add(handler2);

        // act
        final actual = actualComposite.handle(testUri, testState);

        // assert
        expect(actual, equals(expectedResult));
        verifyNever(() => handler1.handle(any(), any()));
        verify(() => handler2.handle(testUri, testState)).called(1);
      });

      test(
        'falls through from the last handler (null) to earlier handlers in '
        'reverse order',
        () {
          // arrange
          final expectedResult = DeeplinkHandlerResult.navigate(testState);
          final handler1 = DeeplinkHandlerMock();
          final handler2 = DeeplinkHandlerMock();
          final handler3 = DeeplinkHandlerMock();
          when(() => handler3.handle(any(), any())).thenReturn(null);
          when(() => handler2.handle(any(), any())).thenReturn(expectedResult);
          final actualComposite = CompositeDeeplinkHandler(
            strategy: const DeeplinkHandlerStrategy.lifo(),
          )
            ..add(handler1)
            ..add(handler2)
            ..add(handler3);

          // act
          final actual = actualComposite.handle(testUri, testState);

          // assert: last (handler3) invoked first, then handler2 which
          // returns the result. handler1 is never reached because the
          // iteration stopped on a non-null from handler2.
          expect(actual, equals(expectedResult));
          verifyInOrder([
            () => handler3.handle(testUri, testState),
            () => handler2.handle(testUri, testState),
          ]);
          verifyNever(() => handler1.handle(any(), any()));
        },
      );

      test('returns null when there are no handlers registered', () {
        // arrange
        final actualComposite = CompositeDeeplinkHandler(
          strategy: const DeeplinkHandlerStrategy.lifo(),
        );

        // act
        final actual = actualComposite.handle(testUri, testState);

        // assert
        expect(actual, isNull);
      });

      test(
        'with a single handler matches FIFO single-handler behaviour (the '
        'sole handler is invoked once and its result is returned)',
        () {
          // arrange
          final expectedResult = DeeplinkHandlerResult.navigate(testState);
          final onlyHandler = DeeplinkHandlerMock();
          when(() => onlyHandler.handle(any(), any()))
              .thenReturn(expectedResult);

          final lifoComposite = CompositeDeeplinkHandler(
            strategy: const DeeplinkHandlerStrategy.lifo(),
          )..add(onlyHandler);
          final fifoComposite = CompositeDeeplinkHandler()..add(onlyHandler);

          // act
          final lifoResult = lifoComposite.handle(testUri, testState);
          final fifoResult = fifoComposite.handle(testUri, testState);

          // assert
          expect(lifoResult, equals(expectedResult));
          expect(fifoResult, equals(expectedResult));
          expect(lifoResult, equals(fifoResult));
          verify(() => onlyHandler.handle(testUri, testState)).called(2);
        },
      );
    });

    group('add/remove methods', () {
      test('add appends the handler to the end of the list', () {
        // arrange
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        final actualComposite = CompositeDeeplinkHandler()
          ..add(handler1)
          ..add(handler2);

        // assert
        expect(actualComposite.handlers, hasLength(2));
        expect(actualComposite.handlers.elementAt(0), equals(handler1));
        expect(actualComposite.handlers.elementAt(1), equals(handler2));
      });

      test('remove returns true and drops the handler when it was registered',
          () {
        // arrange
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        final actualComposite = CompositeDeeplinkHandler()
          ..add(handler1)
          ..add(handler2);

        // act
        final actual = actualComposite.remove(handler1);

        // assert
        expect(actual, isTrue);
        expect(actualComposite.handlers, hasLength(1));
        expect(actualComposite.handlers.elementAt(0), equals(handler2));
      });

      test('remove returns false for an unregistered handler', () {
        // arrange
        final handler1 = DeeplinkHandlerMock();
        final handler2 = DeeplinkHandlerMock();
        final actualComposite = CompositeDeeplinkHandler()..add(handler1);

        // act
        final actual = actualComposite.remove(handler2);

        // assert
        expect(actual, isFalse);
        expect(actualComposite.handlers, hasLength(1));
      });
    });

    test('constructor accepts an initial iterable of handlers', () {
      // arrange
      final handler1 = DeeplinkHandlerMock();
      final handler2 = DeeplinkHandlerMock();

      // act
      final actualComposite =
          CompositeDeeplinkHandler(handlers: [handler1, handler2]);

      // assert
      expect(actualComposite.handlers, hasLength(2));
      expect(actualComposite.handlers.elementAt(0), equals(handler1));
      expect(actualComposite.handlers.elementAt(1), equals(handler2));
    });

    test('defaults to FIFO strategy', () {
      // act
      final actualComposite = CompositeDeeplinkHandler();

      // assert
      expect(actualComposite.strategy, isA<FifoDeeplinkHandlerStrategy>());
    });

    test('returns null when there are no handlers registered', () {
      // arrange
      final actualComposite = CompositeDeeplinkHandler();

      // act
      final actual = actualComposite.handle(testUri, testState);

      // assert
      expect(actual, isNull);
    });
  });
}
