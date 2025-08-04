import 'dart:async';

import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_state/src/mixin/state_manager_listener_mixin.dart';
import 'package:yx_state/yx_state.dart';

class MockFunctionHandler<State> extends Mock
    implements FunctionHandler<State> {}

class TestStateManager extends StateManager<int> {
  TestStateManager(super.state, {super.handler});

  Function(int current, int next)? shouldEmitOverride;

  @visibleForTesting
  @override
  bool shouldEmit(int current, int next) {
    final override = shouldEmitOverride;
    if (override != null) {
      return override(current, next);
    }
    return super.shouldEmit(current, next);
  }

  @visibleForTesting
  @override
  void addError(Object error, [StackTrace? stackTrace, Object? identifier]) {
    super.addError(error, stackTrace, identifier);
  }

  @visibleForTesting
  @override
  // ignore: invalid_override_of_non_virtual_member
  Future<void> handle(EmitterHandler<int> handler, {Object? identifier}) {
    return super.handle(handler, identifier: identifier);
  }

  // Track if lifecycle methods are called
  bool onCreateCalled = false;

  // Track if onStart is called
  bool onStartCalled = false;
  Object? startIdentifier;

  // Track if onDone is called
  bool onDoneCalled = false;
  Object? doneIdentifier;

  // Track if onChange is called
  bool onChangeCalled = false;
  int? prevState;
  int? curState;
  Object? onChangeIdentifier;

  // Track if onError is called
  bool onErrorCalled = false;
  Object? lastError;
  StackTrace? lastStackTrace;

  // Track if onClose is called
  bool onCloseCalled = false;

  @visibleForTesting
  @override
  void onCreate() {
    onCreateCalled = true;
    super.onCreate();
  }

  @visibleForTesting
  @override
  void onStart(Object? identifier) {
    onStartCalled = true;
    startIdentifier = identifier;
    super.onStart(identifier);
  }

  @visibleForTesting
  @override
  void onDone(Object? identifier) {
    onDoneCalled = true;
    doneIdentifier = identifier;
    super.onDone(identifier);
  }

  @visibleForTesting
  @override
  void onChange(int currentState, int nextState, Object? identifier) {
    onChangeCalled = true;
    prevState = currentState;
    curState = nextState;
    onChangeIdentifier = identifier;
    super.onChange(currentState, nextState, identifier);
  }

  @visibleForTesting
  @override
  void onError(Object error, StackTrace stackTrace, Object? identifier) {
    lastError = error;
    lastStackTrace = stackTrace;
    onErrorCalled = true;
    super.onError(error, stackTrace, identifier);
  }

  @visibleForTesting
  @override
  void onClose() {
    onCloseCalled = true;
    super.onClose();
  }
}

class TestFunctionHandler implements FunctionHandler<int> {
  @override
  bool get isClosed => _isClosed;

  TestFunctionHandler();

  bool called = false;
  bool _isClosed = false;
  bool isRethrowError = false;

  @override
  Future<void> call(
    EmitterHandler<int> handler,
    Object? identifier, {
    required Emittable<int> onEmit,
    required void Function(Object error, StackTrace stackTrace) onError,
    required void Function() onStart,
    required void Function() onDone,
  }) async {
    called = true;

    final emitter = TestEmitter(onEmit);
    try {
      onStart();

      await handler(emitter);
    } on Object catch (error, stackTrace) {
      onError(error, stackTrace);
      if (isRethrowError) {
        rethrow;
      }
    } finally {
      emitter.setIsDone(true);
      onDone();
    }
  }

  @override
  Future<void> close() async => _isClosed = true;
}

class TestEmitter implements Emitter<int> {
  final Function(int state) onEmit;
  bool isDoneOverride = false;
  TestEmitter(this.onEmit);

  @override
  void call(int state) => onEmit(state);

  @override
  bool get isDone => isDoneOverride;

  void setIsDone(bool value) => isDoneOverride = value;
}

void main() {
  const initialState = 0;

  group('StateManager', () {
    group('constructor', () {
      late TestStateManager stateManager;

      // act
      setUp(() {
        stateManager = TestStateManager(initialState);
      });

      tearDown(() async {
        await stateManager.close();
      });

      test('should call onCreate', () {
        // assert
        expect(stateManager.onCreateCalled, isTrue);
      });

      test('should initial state be provided', () {
        // assert
        expect(stateManager.state, initialState);
      });
    });

    group('listener', () {
      test('should implement StateManagerListenerMixin', () {
        // act
        final stateManager = TestStateManager(initialState);

        // assert
        expect(stateManager, isA<StateManagerListenerMixin>());
      });
    });

    group('default handler', () {
      // need to restore default handler factory after each test
      late FunctionHandlerFactory defaultHandlerFactory;

      setUp(() {
        defaultHandlerFactory = StateManagerOverrides.defaultHandlerFactory;
      });

      tearDown(() {
        StateManagerOverrides.defaultHandlerFactory = defaultHandlerFactory;
      });

      test('default handler from StateManagerOverrides should be used', () {
        // arrange
        var defaultHandlerCalled = false;
        StateManagerOverrides.defaultHandlerFactory = <T extends Object?>() {
          defaultHandlerCalled = true;
          return MockFunctionHandler<T>();
        };

        // act
        // ignore: unused_local_variable
        final stateManager = TestStateManager(initialState);

        // assert
        expect(defaultHandlerCalled, isTrue);
      });

      test(
        'should use updated global handler when defaultHandlerFactory changes',
        () async {
          // arrange
          var firstHandlerCalled = false;
          StateManagerOverrides.defaultHandlerFactory = <T extends Object?>() {
            firstHandlerCalled = true;
            return MockFunctionHandler<T>();
          };

          // act
          // ignore: unused_local_variable
          final stateManager1 = TestStateManager(initialState);

          // assert
          expect(firstHandlerCalled, isTrue);

          // arrange
          var secondHandlerCalled = false;
          StateManagerOverrides.defaultHandlerFactory = <T extends Object?>() {
            secondHandlerCalled = true;
            return MockFunctionHandler<T>();
          };

          // act
          // ignore: unused_local_variable
          final stateManager2 = TestStateManager(initialState);

          // assert
          expect(secondHandlerCalled, isTrue);
        },
      );

      test('should use handler from constructor', () {
        // arrange
        bool handlerCalled = false;
        StateManagerOverrides.defaultHandlerFactory = <T extends Object?>() {
          handlerCalled = true;
          return defaultHandlerFactory<T>();
        };

        // act
        // ignore: unused_local_variable
        final stateManager = TestStateManager(
          initialState,
          handler: MockFunctionHandler<int>(),
        );

        // assert
        expect(handlerCalled, isFalse);
      });
    });

    group('method handle', () {
      late TestFunctionHandler handler;
      late TestStateManager stateManager;

      setUp(() {
        handler = TestFunctionHandler();
        stateManager = TestStateManager(initialState, handler: handler);
      });

      tearDown(() async {
        await stateManager.close();
      });

      test('should call handler.handle', () async {
        // act
        await stateManager.handle((_) async {});

        // assert
        expect(handler.called, isTrue);
      });

      test('should call onError if state manager is closed', () async {
        // arrange
        final stateManager = TestStateManager(initialState, handler: handler);
        await stateManager.close();

        // act
        await stateManager.handle((_) async {});

        // assert
        expect(stateManager.onErrorCalled, isTrue);
        expect(stateManager.lastError, isA<StateError>());
        expect(stateManager.lastStackTrace, isNotNull);
      });

      test('should call onStart', () async {
        // act
        await stateManager.handle((_) async {});

        // assert
        expect(stateManager.onStartCalled, isTrue);
        expect(stateManager.startIdentifier, isNull);
      });

      test('should call onStart with identifier', () async {
        // arrange
        const identifier = 'test';

        // act
        await stateManager.handle(
          (_) async {},
          identifier: identifier,
        );

        // assert
        expect(stateManager.onStartCalled, isTrue);
        expect(stateManager.startIdentifier, equals(identifier));
      });

      test('should emit state', () async {
        // arrange
        const expectedState = 1;

        // act
        await stateManager.handle((emit) async {
          emit(expectedState);
        });

        // assert
        expect(stateManager.state, equals(expectedState));
      });

      test('should emit multiple times', () async {
        // arrange
        const expectedState1 = 1;
        const expectedState2 = 2;

        // act
        await stateManager.handle((emit) async {
          emit(expectedState1);
          await Future.delayed(const Duration(milliseconds: 100));
          emit(expectedState2);
        });

        // assert
        expect(stateManager.state, equals(expectedState2));
      });

      test('should call onError if handler throws error', () async {
        // arrange
        final error = Exception('Test error');

        await stateManager.handle((_) async => throw error);

        // assert
        expect(stateManager.onErrorCalled, isTrue);
        expect(stateManager.lastError, equals(error));
        expect(stateManager.lastStackTrace, isNotNull);
      });

      test('should call onDone', () async {
        // act
        await stateManager.handle((_) async {});

        // assert
        expect(stateManager.onDoneCalled, isTrue);
      });

      test('should call onDone with identifier', () async {
        // arrange
        const identifier = 'test';

        // act
        await stateManager.handle(
          (_) async {},
          identifier: identifier,
        );

        // assert
        expect(stateManager.onDoneCalled, isTrue);
        expect(stateManager.doneIdentifier, equals(identifier));
      });
    });

    group('method addError', () {
      test('should call onError', () {
        // arrange
        final stateManager = TestStateManager(initialState);
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        // act
        stateManager.addError(error, stackTrace);

        // assert
        expect(stateManager.onErrorCalled, isTrue);
        expect(stateManager.lastError, equals(error));
        expect(stateManager.lastStackTrace, equals(stackTrace));
      });
    });

    group('method _emit', () {
      late TestStateManager stateManager;
      late StateManagerBaseTestUtil<int> testUtil;

      setUp(() {
        stateManager = TestStateManager(initialState);
        testUtil = StateManagerBaseTestUtil<int>(stateManager);
      });

      tearDown(() => stateManager.close());

      test('should emit state', () {
        // arrange
        const expectedState = 1;

        // act
        testUtil.emit(expectedState);

        // assert
        expect(stateManager.state, equals(expectedState));
      });

      test('should call onChange', () {
        // arrange
        const expectedState = 1;

        // act
        testUtil.emit(expectedState);

        // assert
        expect(stateManager.onChangeCalled, isTrue);
        expect(stateManager.prevState, equals(initialState));
        expect(stateManager.curState, equals(expectedState));
        expect(stateManager.onChangeIdentifier, testUtil.identifier);
      });

      test('should throw StateError if state manager is closed', () async {
        // arrange
        final stateManager = TestStateManager(initialState);
        final testUtil = StateManagerBaseTestUtil<int>(stateManager);

        // act
        await stateManager.close();

        // assert
        expect(() => testUtil.emit(1), throwsStateError);
        expect(stateManager.onErrorCalled, isTrue);
        expect(stateManager.lastError, isA<StateError>());
        expect(stateManager.lastStackTrace, isNotNull);
      });

      test('should check shouldEmit', () {
        // arrange
        var shouldEmitCalled = false;

        // act
        stateManager.shouldEmitOverride = (current, next) {
          shouldEmitCalled = true;
          return true;
        };

        // act
        testUtil.emit(1);

        // assert
        expect(shouldEmitCalled, isTrue);
      });

      test('should emit state if it is the same as the current state', () {
        // arrange
        const expectedState = 0;

        // act
        testUtil.emit(expectedState);

        // assert
        expect(stateManager.state, same(expectedState));
        expect(stateManager.onChangeCalled, isFalse);
      });

      test('should emit state if it is not the same as the current state', () {
        // arrange
        const expectedState = 1;

        // act
        testUtil.emit(expectedState);

        // assert
        expect(stateManager.state, same(expectedState));
        expect(stateManager.onChangeCalled, isTrue);
        expect(stateManager.prevState, equals(initialState));
        expect(stateManager.curState, equals(expectedState));
      });
    });

    group('method close', () {
      late MockFunctionHandler<int> handler;

      setUp(() {
        handler = MockFunctionHandler<int>();
      });

      test('should call handler.close', () async {
        // arrange
        final stateManager = TestStateManager(
          initialState,
          handler: handler,
        );

        // act
        await stateManager.close();

        // assert
        verify(() => handler.close()).called(1);
      });

      test('should call observer.onClose', () async {
        // arrange
        final stateManager = TestStateManager(initialState);

        // act
        await stateManager.close();

        // assert
        expect(stateManager.onCloseCalled, isTrue);
      });

      test('should isClosed return true', () async {
        // arrange
        final stateManager = TestStateManager(initialState);

        // assert
        expect(stateManager.isClosed, isFalse);

        // act
        await stateManager.close();

        // assert
        expect(stateManager.isClosed, isTrue);
      });
    });

    group('method shouldEmit', () {
      late TestStateManager stateManager;
      late StateManagerBaseTestUtil<int> testUtil;

      setUp(() {
        stateManager = TestStateManager(initialState);
        testUtil = StateManagerBaseTestUtil<int>(stateManager);
      });

      tearDown(() => stateManager.close());

      test('should emit state if shouldEmitOverride returns true', () {
        // arrange
        stateManager.shouldEmitOverride = (current, next) => true;
        const expectedState = 1;

        // act
        testUtil.emit(expectedState);

        // assert
        expect(stateManager.onChangeCalled, isTrue);
        expect(stateManager.prevState, equals(initialState));
        expect(stateManager.curState, equals(expectedState));
      });

      test('should not emit state if shouldEmitOverride returns false', () {
        // arrange
        stateManager.shouldEmitOverride = (current, next) => false;
        const expectedState = 1;

        // act
        testUtil.emit(expectedState);

        // assert
        expect(stateManager.onChangeCalled, isFalse);
        expect(stateManager.state, equals(initialState));
      });

      test('should call onError if shouldEmitOverride throws an error', () {
        // arrange
        final error = Exception('Test error');
        stateManager.shouldEmitOverride = (_, __) => throw error;

        // act & assert
        expect(() => testUtil.emit(1), throwsException);
        expect(stateManager.onErrorCalled, isTrue);
        expect(stateManager.lastError, equals(error));
        expect(stateManager.lastStackTrace, isNotNull);
      });
    });
  });
}
