import 'package:meta/meta.dart';

import '../base/interface.dart';
import '../base/state_manager_base.dart';
import '../state_manager_observer.dart';
import '../state_manager_overrides.dart';

/// A mixin that provides default lifecycle event handling for state managers.
///
/// This mixin implements the [StateManagerListener] interface and forwards
/// all lifecycle events to the global [StateManagerObserver] configured in
/// [StateManagerOverrides].
///
/// The mixin is typically used with [StateManagerBase] to provide standard
/// event observation capabilities with minimal boilerplate.
@internal
mixin StateManagerListenerMixin<State extends Object?>
    on StateManagerBase<State> implements StateManagerListener<State> {
  /// The observer that will receive lifecycle events from this state manager.
  ///
  /// By default, this returns the global observer from [StateManagerOverrides].
  StateManagerObserver get _observer => StateManagerOverrides.observer;

  /// Called when the state manager is created.
  ///
  /// Forwards the creation event to the observer.
  @mustCallSuper
  @protected
  @override
  void onCreate() => _observer.onCreate(this);

  /// Called when a handler function starts execution.
  ///
  /// Forwards the handler start event to the observer with the optional identifier.
  @mustCallSuper
  @protected
  @override
  void onStart(Object? identifier) => _observer.onHandleStart(this, identifier);

  /// Called when a handler function completes execution.
  ///
  /// Forwards the handler completion event to the observer with the optional identifier.
  @mustCallSuper
  @protected
  @override
  void onDone(Object? identifier) => _observer.onHandleDone(this, identifier);

  /// Called when the state changes.
  ///
  /// Forwards the state change event to the observer with the current and next state.
  @mustCallSuper
  @protected
  @override
  void onChange(State currentState, State nextState, Object? identifier) =>
      _observer.onChange(this, currentState, nextState, identifier);

  /// Called when an error occurs within the state manager.
  ///
  /// Forwards the error event to the observer with the error and stack trace.
  @mustCallSuper
  @protected
  @override
  void onError(Object error, StackTrace stackTrace, Object? identifier) =>
      _observer.onError(this, error, stackTrace, identifier);

  /// Called when the state manager is closed.
  ///
  /// Forwards the close event to the observer.
  @mustCallSuper
  @protected
  @override
  void onClose() => _observer.onClose(this);
}
