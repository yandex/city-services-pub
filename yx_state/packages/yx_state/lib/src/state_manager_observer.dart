import 'package:meta/meta.dart';

import 'base/state_manager_base.dart';

/// An abstract class for observing state manager lifecycle events.
///
/// The observer pattern allows you to monitor and respond to various events
/// in the state management lifecycle across your application. You can extend
/// this class to create custom observers for logging, analytics, debugging,
/// or any other cross-cutting concern.
///
/// To use a custom observer, assign it to [StateManagerOverrides.observer]:
/// ```dart
/// class MyCustomObserver extends StateManagerObserver {
///   @override
///   void onChange(
///     StateManagerBase stateManager,
///     Object? currentState,
///     Object? nextState,
///     Object? identifier,
///   ) {
///     print('State changed from $currentState to $nextState with identifier: $identifier');
///     super.onChange(stateManager, currentState, nextState, identifier);
///   }
/// }
///
/// // Set the observer globally
/// StateManagerOverrides.observer = MyCustomObserver();
/// ```
abstract class StateManagerObserver {
  /// Creates a new [StateManagerObserver] instance.
  const StateManagerObserver();

  /// Called when a state manager is created.
  ///
  /// This is the first lifecycle method called, right after the state manager
  /// is instantiated with its initial state.
  ///
  /// [stateManager] - The state manager that was created
  @mustCallSuper
  void onCreate(StateManagerBase<Object?> stateManager) {}

  /// Called when a state change occurs.
  ///
  /// This method is invoked whenever a new state is emitted by the state manager,
  /// providing both the previous state and the new state.
  ///
  /// [stateManager] - The state manager where the change occurred
  /// [currentState] - The previous state value
  /// [nextState] - The new state value
  /// [identifier] - An optional identifier for the handler
  @mustCallSuper
  void onChange(
    StateManagerBase<Object?> stateManager,
    Object? currentState,
    Object? nextState,
    Object? identifier,
  ) {}

  /// Called when an error occurs within a state manager.
  ///
  /// This method is invoked whenever an exception is caught during state
  /// management operations.
  ///
  /// [stateManager] - The state manager where the error occurred
  /// [error] - The error that was thrown
  /// [stackTrace] - The stack trace associated with the error
  /// [identifier] - An optional identifier for the handler
  @mustCallSuper
  void onError(
    StateManagerBase<Object?> stateManager,
    Object error,
    StackTrace stackTrace,
    Object? identifier,
  ) {}

  /// Called when a handler function starts execution.
  ///
  /// This method is invoked at the beginning of each handler function's lifecycle.
  ///
  /// [stateManager] - The state manager handling the function
  /// [identifier] - An optional identifier for the handler function
  @mustCallSuper
  void onHandleStart(
    StateManagerBase<Object?> stateManager,
    Object? identifier,
  ) {}

  /// Called when a handler function completes execution.
  ///
  /// This method is invoked after a handler function has completed,
  /// regardless of whether it was successful or threw an error.
  ///
  /// [stateManager] - The state manager handling the function
  /// [identifier] - An optional identifier for the handler function
  @mustCallSuper
  void onHandleDone(
    StateManagerBase<Object?> stateManager,
    Object? identifier,
  ) {}

  /// Called when a state manager is closed.
  ///
  /// This is the final lifecycle method called when a state manager
  /// is being disposed and will no longer emit state updates.
  ///
  /// [stateManager] - The state manager that was closed
  @mustCallSuper
  void onClose(StateManagerBase<Object?> stateManager) {}
}
