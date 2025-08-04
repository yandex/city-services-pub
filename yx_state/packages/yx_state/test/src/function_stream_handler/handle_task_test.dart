import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_state/yx_state.dart';

import '../mocks.dart';

class TestHandlerHelper<State extends Object?> {
  Object? identifier;

  bool isStartCalled = false;
  void onStart() {
    isStartCalled = true;
  }

  bool isDoneCalled = false;
  void onDone() {
    isDoneCalled = true;
  }

  Future<void> Function(Emitter<State> emit)? onHandleCallback;
  Future<void> handle(Emitter<State> emit) async {
    await onHandleCallback?.call(emit);
  }

  // ignore: unused_element
  void onEmit(State state) {}
}

void main() {
  group('HandleTaskImpl', () {
    late TestHandlerHelper<int> testHandlerHelper;
    late MockHandleTaskEmitter<int> handleTaskEmitter;
    late HandleTask<int> handleTask;

    setUp(() {
      testHandlerHelper = TestHandlerHelper<int>();
      handleTaskEmitter = MockHandleTaskEmitter<int>();
      handleTask = HandleTask<int>(
        testHandlerHelper.handle,
        testHandlerHelper.identifier,
        testHandlerHelper.onEmit,
        testHandlerHelper.onStart,
        testHandlerHelper.onDone,
        emitter: handleTaskEmitter,
      );

      registerFallbackValue(StackTrace.empty);
    });

    group('method cancel', () {
      test('should call the emitter', () {
        // arrange
        when(() => handleTaskEmitter.cancel())
            .thenAnswer((_) => Future.value());

        // act
        handleTask.cancel();

        // assert
        verify(() => handleTaskEmitter.cancel()).called(1);
      });
    });

    group('method handle', () {
      setUp(() {
        when(() => handleTask.isDone).thenReturn(false);
      });

      test('should call onBegin when the handle is called', () async {
        // arrange
        bool isBeginCalled = false;

        // act
        await handleTask.handle(() => isBeginCalled = true, () {});

        // assert
        expect(isBeginCalled, isTrue);
      });

      test('should call onStart when the handle is called', () async {
        // arrange
        expect(testHandlerHelper.isStartCalled, isFalse);

        // act
        await handleTask.handle(() {}, () {});

        // assert
        expect(testHandlerHelper.isStartCalled, isTrue);
      });

      test('should call handle when the handle is called', () async {
        // arrange
        bool isHandleCalled = false;
        testHandlerHelper.onHandleCallback = (emit) async {
          isHandleCalled = true;
        };

        // act
        await handleTask.handle(() {}, () {});

        // assert
        expect(isHandleCalled, isTrue);
      });

      test('should emit the state when the handle is called', () async {
        // arrange
        final expected = 1;
        testHandlerHelper.onHandleCallback = (emit) async {
          emit(expected);
        };

        // act
        await handleTask.handle(() {}, () {});

        // assert
        verify(() => handleTaskEmitter.call(expected)).called(1);
      });

      test('should call completeError if the handle throws an error', () async {
        // arrange
        testHandlerHelper.onHandleCallback = (emit) async {
          throw Exception();
        };

        // act
        await handleTask.handle(() {}, () {});

        // assert
        verify(
          () => handleTaskEmitter.completeError(
            isA<Exception>(),
            any(),
          ),
        ).called(1);
      });

      test('should not call completeError if emitter isNotDone', () async {
        // arrange
        testHandlerHelper.onHandleCallback = (emit) async {
          when(() => handleTaskEmitter.isDone).thenReturn(true);
          throw Exception();
        };

        // act
        await handleTask.handle(() {}, () {});

        // assert
        verifyNever(
          () => handleTaskEmitter.completeError(
            isA<Exception>(),
            any(),
          ),
        );
      });

      test('should call complete after the handler has completed', () async {
        // arrange
        testHandlerHelper.onHandleCallback = (emit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        };

        // act
        await handleTask.handle(() {}, () {});

        // assert
        verify(() => handleTaskEmitter.complete()).called(1);
      });

      test('should not call complete if emitter isDone', () async {
        // arrange
        testHandlerHelper.onHandleCallback = (emit) async {
          when(() => handleTaskEmitter.isDone).thenReturn(true);
        };

        // act
        await handleTask.handle(() {}, () {});

        // assert
        verifyNever(() => handleTaskEmitter.complete());
      });

      test('should call onComplete after the handler has completed', () async {
        // arrange
        bool isCompleteCalled = false;

        // act
        await handleTask.handle(() {}, () => isCompleteCalled = true);

        // assert
        expect(isCompleteCalled, isTrue);
      });

      test('should call onDone after the handler has completed', () async {
        // arrange
        expect(testHandlerHelper.isDoneCalled, isFalse);

        // act
        await handleTask.handle(() {}, () {});

        // assert
        expect(testHandlerHelper.isDoneCalled, isTrue);
      });
    });
  });
}
