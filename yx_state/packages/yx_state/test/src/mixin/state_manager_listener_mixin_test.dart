import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_state/src/mixin/state_manager_listener_mixin.dart';
import 'package:yx_state/yx_state.dart';

import '../mocks.dart';

class TestStateManager extends StateManagerBase<int>
    with StateManagerListenerMixin<int> {
  TestStateManager(super.state, {required super.handler});

  @override
  void onCreate() {
    super.onCreate();
  }

  @override
  void onStart(Object? identifier) {
    super.onStart(identifier);
  }

  @override
  void onDone(Object? identifier) {
    super.onDone(identifier);
  }

  @override
  void onChange(int current, int next, Object? identifier) {
    super.onChange(current, next, identifier);
  }

  @override
  void onError(Object error, StackTrace stackTrace, Object? identifier) {
    super.onError(error, stackTrace, identifier);
  }

  @override
  void onClose() {
    super.onClose();
  }
}

void main() {
  group('StateManagerListenerMixin', () {
    late StateManagerObserver originalObserver;

    late MockStateManagerObserver observer;
    late MockFunctionHandler<int> handler;
    late TestStateManager stateManager;

    setUp(() {
      observer = MockStateManagerObserver();

      originalObserver = StateManagerOverrides.observer;
      StateManagerOverrides.observer = observer;

      handler = MockFunctionHandler();
      stateManager = TestStateManager(0, handler: handler);
    });

    tearDown(() async {
      await stateManager.close();
      reset(observer);
      StateManagerOverrides.observer = originalObserver;
    });

    test('should call onCreate', () {
      // assert
      // 1 time because constructor already calls it
      verify(() => observer.onCreate(stateManager)).called(1);

      // act
      stateManager.onCreate();

      // assert
      verify(() => observer.onCreate(stateManager)).called(1);
    });

    test('should call onStart', () {
      // arrange
      const identifier = 'test';

      // act
      stateManager.onStart(identifier);

      // assert
      verify(() => observer.onHandleStart(stateManager, identifier)).called(1);
    });

    test('should call onDone', () {
      // arrange
      const identifier = 'test';

      // act
      stateManager.onDone(identifier);

      // assert
      verify(() => observer.onHandleDone(stateManager, identifier)).called(1);
    });

    test('should call onChange', () {
      // arrange
      const current = 1;
      const next = 2;
      const identifier = 'test';

      // act
      stateManager.onChange(current, next, identifier);

      // assert
      verify(
        () => observer.onChange(stateManager, current, next, identifier),
      ).called(1);
    });

    test('should call onError', () {
      // arrange
      final error = Exception();
      final stackTrace = StackTrace.current;
      const identifier = 'test';

      // act
      stateManager.onError(error, stackTrace, identifier);

      // assert
      verify(
        () => observer.onError(stateManager, error, stackTrace, identifier),
      ).called(1);
    });

    test('should call onClose', () {
      // act
      stateManager.onClose();

      // assert
      verify(() => observer.onClose(stateManager)).called(1);
    });
  });
}
