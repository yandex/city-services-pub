import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

/// {@template state_manager_configuration}
/// Groups state-management parameters for `RouterSchema.build`.
///
/// Holds an optional [RouteNodeStateManager] and the observers that receive
/// state-manager and guard-execution events.
/// {@endtemplate}
@immutable
class StateManagerConfiguration {
  /// State manager driving the navigation state.
  final RouteNodeStateManager? stateManager;

  /// Observer notified about [RouteNodeStateManager] events.
  final StateManagerObserver? stateManagerObserver;

  /// Observer notified about guard execution.
  final GuardObserver? guardObserver;

  /// {@macro state_manager_configuration}
  const StateManagerConfiguration({
    this.stateManager,
    this.stateManagerObserver,
    this.guardObserver,
  });
}
