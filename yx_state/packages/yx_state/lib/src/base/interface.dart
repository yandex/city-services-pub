import 'package:meta/meta.dart';

/// An interface for objects that provide read access to a state stream.
///
/// This interface provides the core capabilities for reading state from a state manager:
/// - Access to the current state value via [state]
/// - Access to a stream of state changes via [stream]
///
/// This allows for both reactive (stream-based) and imperative (direct access)
/// consumption of state.
abstract class StateReadable<State extends Object?> {
  /// A stream of state changes.
  ///
  /// This stream emits a new value whenever the state changes.
  /// The stream is a broadcast stream and can be listened to multiple times.
  Stream<State> get stream;

  /// The current state value.
  ///
  /// This getter always returns the most up-to-date state value.
  State get state;
}

/// Interface for objects that can emit new state values
/// and track completion status.
///
/// See also:
///
/// * [FunctionHandler] which has access to an [Emitter].
abstract class Emitter<State extends Object?> {
  /// Indicates whether this emitter should accept new states.
  ///
  /// Returns `true` if the emitter has been closed or completed,
  /// and no more state updates should be accepted.
  bool get isDone;

  /// Update the current state with a new [state] value.
  ///
  /// Asserts that the emitter is not done before emitting the state.
  void call(State state);
}

/// Function signature for asynchronous state management operations
/// that use an [Emitter].
typedef EmitterHandler<State extends Object?> = Future<void> Function(
  Emitter<State> emit,
);

/// Callback type for updating state by providing a new [State] value.
typedef Emittable<State extends Object?> = void Function(
  State state,
);

/// Handles the processing of state update functions.
///
/// Different implementations provide various concurrency strategies.
abstract class FunctionHandler<State extends Object?> implements Closable {
  /// Executes the provided handler function with the necessary lifecycle callbacks.
  ///
  /// Throws [StateError] if called after this handler has been closed.
  Future<void> call(
    EmitterHandler<State> handler,
    Object? identifier, {
    required Emittable<State> onEmit,
    required void Function(Object error, StackTrace stackTrace) onError,
    required void Function() onStart,
    required void Function() onDone,
  });
}

/// An interface for objects that can be closed and have a closure state.
///
/// Classes implementing this interface should guarantee that once closed:
/// - No further operations should be performed on the object
/// - All resources should be released
/// - The [isClosed] property should return true
@internal
abstract class Closable {
  /// Indicates whether the object has been closed.
  ///
  /// Returns:
  /// - `true` if the object has been successfully closed
  /// - `false` if the object is still active and operational
  bool get isClosed;

  /// Closes the object and releases associated resources.
  ///
  /// This method should be idempotent - calling it multiple times
  /// should have the same effect as calling it once.
  ///
  /// Returns:
  /// A [Future] that completes when the closure operation finishes.
  Future<void> close();
}

/// An internal interface for handling state manager lifecycle events.
///
/// This interface defines the core lifecycle methods that a state manager
/// needs to implement to properly track and report its state changes and
/// other important events.
///
/// It's typically implemented by [StateManagerBase] and its subclasses.
@internal
abstract class StateManagerListener<State extends Object?> {
  /// Called when the state manager is created.
  void onCreate();

  /// Called when a handler function starts execution.
  ///
  /// [identifier] - An optional identifier for the handler
  void onStart(Object? identifier);

  /// Called when a handler function completes execution.
  ///
  /// [identifier] - An optional identifier for the handler
  void onDone(Object? identifier);

  /// Called when the state changes.
  ///
  /// [currentState] - The previous state value
  /// [nextState] - The new state value
  /// [identifier] - An optional identifier for the handler
  void onChange(State currentState, State nextState, Object? identifier);

  /// Called when an error occurs within the state manager.
  ///
  /// [error] - The error that was thrown
  /// [stackTrace] - The stack trace associated with the error
  /// [identifier] - An optional identifier for the handler
  void onError(Object error, StackTrace stackTrace, Object? identifier);

  /// Called when the state manager is closed.
  void onClose();
}

/// An internal interface for handling state update operations.
///
/// This interface defines the core method for processing state updates
/// through handler functions.
///
/// It's typically implemented by [StateManagerBase] and its subclasses.
@internal
abstract class StateManagerHandler<State extends Object?> {
  /// Processes a state update handler function.
  ///
  /// This method is the central point for executing state update logic
  /// and managing the lifecycle of state updates.
  ///
  /// [handler] - The handler function that will potentially update the state
  /// [identifier] - An optional identifier for the handler
  Future<void> handle(
    EmitterHandler<State> handler, {
    Object? identifier,
  });
}
