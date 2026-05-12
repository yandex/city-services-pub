import 'package:meta/meta.dart';

import 'base_state_manager.dart';
import 'mutation.dart';

/// {@template state_manager_observer}
/// Hooks into the lifecycle of a [BaseStateManager].
///
/// Override the methods that matter to your use case (for example, logging
/// or metrics). All default implementations are no-ops and must be called
/// via `super` when overridden.
/// {@endtemplate}
abstract class StateManagerObserver {
  /// {@macro state_manager_observer}
  const StateManagerObserver();

  /// Called when a [BaseStateManager] is constructed.
  @mustCallSuper
  void onCreate(BaseStateManager stateManager) {}

  /// Called when a [Mutation] is applied to [stateManager].
  @mustCallSuper
  void onMutation(
    BaseStateManager stateManager,
    Mutation mutation,
  ) {}

  /// Called when an [error] with [stackTrace] is thrown inside
  /// [stateManager].
  @mustCallSuper
  void onError(
    BaseStateManager stateManager,
    Object error,
    StackTrace stackTrace,
  ) {}

  /// Called when [stateManager] is closed.
  @mustCallSuper
  void onClose(BaseStateManager stateManager) {}
}
