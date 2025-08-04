import 'package:yx_state/yx_state.dart';

void main() {
  // Set the observer globally
  StateManagerOverrides.observer = const MyCustomObserver();

  // Create a new state manager
  final counter = CounterStateManager(0);

  counter.increment();
  counter.decrement();
  counter.someLogic();
  counter.increment();
  counter.incrementBy(5);

  // Close the state manager
  counter.close();
}

class CounterStateManager extends StateManager<int> {
  CounterStateManager(super.state);

  void increment() => handle((emit) async {
        await Future.delayed(const Duration(seconds: 1));
        emit(state + 1);
      }, identifier: 'increment');

  void incrementBy(int value) => handle((emit) async {
        await Future.delayed(const Duration(seconds: 1));
        emit(state + value);
      }, identifier: {'value': value});

  void decrement() => handle((emit) async {
        await Future.delayed(const Duration(seconds: 1));
        emit(state - 1);
      }, identifier: 'decrement');

  void someLogic() => handle((emit) async {
        try {
          if (state == 0) {
            throw Exception();
          }

          emit(state);
        } on Object catch (error, sk) {
          addError(error, sk, 'someLogic');
        }

        emit(0);
      }, identifier: 'someLogic');
}

class MyCustomObserver extends StateManagerObserver {
  const MyCustomObserver();

  @override
  void onChange(
    StateManagerBase<Object?> stateManager,
    Object? currentState,
    Object? nextState,
    Object? identifier,
  ) {
    print(
      'State changed from $currentState to $nextState '
      'identifier: $identifier',
    );
    super.onChange(stateManager, currentState, nextState, identifier);
  }

  @override
  void onHandleStart(
    StateManagerBase<Object?> stateManager,
    Object? identifier,
  ) {
    print('Handle started: $identifier');
    super.onHandleStart(stateManager, identifier);
  }

  @override
  void onHandleDone(
    StateManagerBase<Object?> stateManager,
    Object? identifier,
  ) {
    print('Handle done: $identifier');
    super.onHandleDone(stateManager, identifier);
  }

  @override
  void onError(
    StateManagerBase<Object?> stateManager,
    Object error,
    StackTrace stackTrace,
    Object? identifier,
  ) {
    print(
      'Oops error: $error, stackTrace: $stackTrace '
      'identifier: $identifier',
    );
    super.onError(stateManager, error, stackTrace, identifier);
  }
}
