import 'base/interface.dart';
import 'base/state_manager_base.dart';
import 'mixin/state_manager_listener_mixin.dart';
import 'state_manager_overrides.dart';

/// Main class for state management that should be extended by users.
///
/// This class combines the core state management functionality from
/// [StateManagerBase] with the default listener implementation from
/// [StateManagerListenerMixin].
///
/// Usage example:
/// ```dart
/// class CounterState {
///   final int count;
///
///   CounterState(this.count);
/// }
///
/// class CounterManager extends StateManager<CounterState> {
///   CounterManager() : super(CounterState(0));
///
///   Future<void> increment() => handle((emit) async {
///     emit(CounterState(state.count + 1));
///   });
///
///   Future<void> decrement() => handle((emit) async {
///     emit(CounterState(state.count - 1));
///   });
/// }
/// ```
abstract class StateManager<State extends Object?>
    extends StateManagerBase<State> with StateManagerListenerMixin<State> {
  /// Creates a new [StateManager] with the provided initial [state]
  /// and optional function [handler].
  ///
  /// If no [handler] is provided, the default handler from [StateManagerOverrides.defaultHandlerFactory]
  /// will be used, which is a sequential handler by default.
  StateManager(
    super.state, {
    FunctionHandler<State>? handler,
  }) : super(handler: handler ?? _createDefaultHandler<State>());

  /// Creates a default handler for the given state type.
  ///
  /// This method is used to create a default handler for the given state type.
  /// It uses the [StateManagerOverrides.defaultHandlerFactory] to create a new handler.
  static FunctionHandler<State> _createDefaultHandler<State extends Object?>() {
    return StateManagerOverrides.defaultHandlerFactory<State>();
  }
}
