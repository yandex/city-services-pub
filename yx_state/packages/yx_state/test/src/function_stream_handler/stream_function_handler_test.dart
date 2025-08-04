import 'dart:async';

import 'package:test/test.dart';
import 'package:yx_state/yx_state.dart';

// Define a HandleTaskTransformer function
Stream<HandleTask<State>> testTransformer<State extends Object?>(
  Stream<HandleTask<State>> tasks,
  HandleTaskMapper<State> mapper,
) =>
    tasks.asyncExpand(mapper);

void main() {
  group('StreamFunctionHandler', () {
    late StreamFunctionHandler<int> handler;

    setUp(() {
      handler = StreamFunctionHandler<int>(
        handleTransformer: testTransformer,
      );
    });

    tearDown(() async {
      // Clean up resources
      await handler.close();
    });

    group('getter isClosed', () {
      test('should return false when the handler is not closed', () {
        // assert
        expect(handler.isClosed, isFalse);
      });

      test('should return true when the handler is closed', () async {
        // act
        await handler.close();

        // assert
        expect(handler.isClosed, isTrue);
      });
    });

    group('method close', () {
      test('should be idempotent', () async {
        // arrange
        await handler.close();

        // act
        await handler.close(); // Second call should not throw

        // assert
        expect(handler.isClosed, isTrue);
      });
    });

    group('method call', () {
      test('should throw StateError when calling after closed', () async {
        // arrange
        await handler.close();

        // act & assert
        expect(
          () => handler.call(
            (emit) async {},
            null,
            onEmit: (_) {},
            onError: (_, __) {},
            onStart: () {},
            onDone: () {},
          ),
          throwsStateError,
        );
      });

      test('should handle errors from the task', () async {
        // arrange
        final error = Exception('Test error');
        bool errorCalled = false;

        // act & assert
        await handler.call(
          (emit) => throw error,
          null,
          onEmit: (_) {},
          onError: (error, _) {
            expect(error, equals(error));
            errorCalled = true;
          },
          onStart: () {},
          onDone: () {},
        );

        // assert
        expect(errorCalled, isTrue);
      });

      test('should call onEmit for each task', () async {
        // arrange
        final expectedValue = 0;

        // act & assert
        await handler.call(
          (emit) async => emit(expectedValue),
          null,
          onEmit: (value) => expect(value, equals(expectedValue)),
          onError: (_, __) {},
          onStart: () {},
          onDone: () {},
        );
      });

      test('should emit the correct value for each task', () async {
        // act & assert
        for (var i = 0; i < 3; i++) {
          handler.call(
            (emit) async {
              // Just emit something
              emit(i);
            },
            'test_$i',
            onEmit: (value) => expect(value, equals(i)),
            onError: (_, __) {},
            onStart: () {},
            onDone: () {},
          );
        }
      });

      test('should complete all future tasks after close', () async {
        // act & assert
        for (var i = 0; i < 3; i++) {
          expectLater(
            handler.call(
              (emit) async {},
              null,
              onEmit: (value) {},
              onError: (_, __) {},
              onStart: () {},
              onDone: () {},
            ),
            completes,
          );
        }

        // act
        await handler.close();
      });

      test('should complete all future tasks with error', () async {
        // arrange & act & assert
        for (var i = 0; i < 3; i++) {
          final error = Exception('Test error $i');

          expectLater(
            handler.call(
              (emit) async => throw error,
              null,
              onEmit: (value) {},
              onError: (error, _) => expect(error, equals(error)),
              onStart: () {},
              onDone: () {},
            ),
            completes, // completes with out error
          );
        }

        // act
        await handler.close();
      });
    });
  });
}
