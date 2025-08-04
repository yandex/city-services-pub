import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_state/src/function_stream_handler/handle_task_emitter.dart';

import '../mocks.dart';

void main() {
  group('HandleTaskEmitter', () {
    late MockEmitter<int> mockEmitter;
    late HandleTaskEmitter<int> handleTaskEmitter;

    setUp(() {
      mockEmitter = MockEmitter<int>();
      handleTaskEmitter = HandleTaskEmitter<int>(mockEmitter.call);
    });

    group('method call', () {
      test('should throw assert if the emitter is completed', () {
        // arrange
        handleTaskEmitter.complete();

        // act & assert
        expect(() => handleTaskEmitter.call(1), throwsA(isA<AssertionError>()));
      });

      test('should not emit if the emitter is canceled', () {
        // arrange
        handleTaskEmitter.cancel();

        // act
        handleTaskEmitter.call(1);

        // assert
        verifyNever(() => mockEmitter.call(any()));
      });

      test('should emit if the emitter is not canceled', () {
        // arrange
        const expected = 1;

        // act
        handleTaskEmitter.call(1);

        // assert
        verify(() => mockEmitter.call(expected)).called(1);
      });
    });

    group('method cancel', () {
      test('should cancel the emitter', () {
        // assert
        expect(handleTaskEmitter.isCanceled, isFalse);

        // act
        handleTaskEmitter.cancel();

        // assert
        expect(handleTaskEmitter.isCanceled, isTrue);
      });

      test('should set isDone to true', () {
        // assert
        expect(handleTaskEmitter.isDone, isFalse);

        // act
        handleTaskEmitter.cancel();

        // assert
        expect(handleTaskEmitter.isDone, isTrue);
      });

      test('should complete the future', () {
        // assert
        expectLater(handleTaskEmitter.future, completes);

        // act
        handleTaskEmitter.cancel();
      });
    });

    group('method complete', () {
      test('should set isDone to true', () {
        // assert
        expect(handleTaskEmitter.isDone, isFalse);

        // act
        handleTaskEmitter.complete();

        // assert
        expect(handleTaskEmitter.isDone, isTrue);
      });

      test('should complete the future', () {
        // assert
        expectLater(handleTaskEmitter.future, completes);

        // act
        handleTaskEmitter.complete();
      });
    });

    group('method completeError', () {
      test('should complete the future with an error', () {
        // assert
        expectLater(handleTaskEmitter.future, throwsException);

        // act
        handleTaskEmitter.completeError(Exception(), StackTrace.current);
      });

      test('should set isDone to true', () {
        // assert
        expect(handleTaskEmitter.isDone, isFalse);
        // need because completer throw exception to zone
        expect(handleTaskEmitter.future, throwsException);

        // act
        handleTaskEmitter.completeError(Exception(), StackTrace.current);

        // assert
        expect(handleTaskEmitter.isDone, isTrue);
      });
    });
  });
}
