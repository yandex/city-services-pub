import 'package:yx_state/yx_state.dart';

/// A factory function that creates a [FunctionHandler] with a specific state type.
typedef FunctionHandlerFactory = FunctionHandler<State>
    Function<State extends Object?>();

/// Global configuration for state managers.
///
/// This class provides a way to override default behaviors across all state managers
/// in your application. It defines global settings like the default observer and
/// function handler factory used by state managers.
///
/// You can customize these settings to apply consistent behavior across your
/// entire application without having to configure each state manager individually.
///
/// Example:
/// ```dart
/// // Set a custom observer for all state managers
/// StateManagerOverrides.observer = MyCustomObserver();
/// ```
abstract class StateManagerOverrides {
  /// The default [StateManagerObserver] implementation.
  ///
  /// This observer provides basic logging and error handling for state manager events.
  /// It can be overridden to provide custom observer behavior.
  ///
  /// Example:
  /// ```dart
  /// class MyObserver extends StateManagerObserver {
  ///   @override
  ///   void onCreate<State extends Object?>(StateManagerBase<State> manager) {
  ///     print('${manager.runtimeType} created with initial state: ${manager.state}');
  ///     super.onCreate(manager);
  ///   }
  /// }
  ///
  /// // Set the custom observer
  /// StateManagerOverrides.observer = MyObserver();
  /// ```
  static StateManagerObserver observer = const _DefaultStateManagerObserver();

  /// Factory function that creates the default [FunctionHandler] for state managers.
  ///
  /// By default, this returns a sequential function handler, which processes tasks
  /// one at a time in a queue. This can be changed to use a different handler type
  /// globally across the application.
  ///
  /// See also:
  ///
  /// * [package:yx_state_transformers](https://pub.dev/packages/yx_state_transformers)
  static FunctionHandlerFactory defaultHandlerFactory =
      <State extends Object?>() => StreamFunctionHandler<State>(
          handleTransformer: (tasks, mapper) => tasks.asyncExpand(mapper));

  /// The default shouldEmit implementation.
  ///
  /// This implementation compares the current state and the next state using the
  /// `!=` operator.
  ///
  /// This can be overridden to provide a custom shouldEmit implementation.
  ///
  /// Example:
  /// ```dart
  /// StateManagerOverrides.defaultShouldEmit = (current, next) => true;
  /// ```
  static bool Function(Object? current, Object? next) defaultShouldEmit =
      (current, next) => current != next;
}

/// The default implementation of [StateManagerObserver].
///
/// This observer provides a minimal implementation that doesn't perform any actions
/// when state manager events occur. It serves as a no-op placeholder until a custom
/// observer is provided.
///
/// This allows the state management system to have a non-null observer by default,
/// which simplifies the internal code by avoiding null checks.
///
/// To add custom observation behavior, create your own observer class and set it
/// as the global observer:
/// ```dart
/// class LoggingObserver extends StateManagerObserver {
///   @override
///   void onChange(
///     StateManagerBase stateManager,
///     Object? currentState,
///     Object? nextState,
///     Object? identifier,
///   ) {
///     print('${stateManager.runtimeType}: $currentState -> $nextState (identifier: $identifier)');
///     super.onChange(stateManager, currentState, nextState, identifier);
///   }
/// }
///
/// StateManagerOverrides.observer = LoggingObserver();
/// ```
class _DefaultStateManagerObserver extends StateManagerObserver {
  const _DefaultStateManagerObserver();
}
