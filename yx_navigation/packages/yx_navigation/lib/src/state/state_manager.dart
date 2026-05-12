import 'dart:async';

import 'package:meta/meta.dart';

import '../base/route_navigator.dart';
import '../base/route_node.dart';
import '../guard/guard_context.dart';
import '../guard/guard_result.dart';
import '../guard/guard_sync.dart';
import '../guard/route_node_guard.dart';
import 'base/base_state_manager.dart';

/// {@template state_manager}
/// The primary state manager that holds the current navigation tree and
/// coordinates every mutation.
///
/// [RouteNodeStateManager] keeps the active [RouteNode] as immutable state, exposes
/// it via [RouteNodeReadable.state] and [RouteNodeReadable.stream], and
/// runs the configured [RouteNodeGuard] pipeline on every mutation produced by
/// [RouteNodeStateManager.mutate]. Based on the [GuardResult] the manager either commits the
/// proposed state, redirects to a different node, or cancels the change.
///
/// A [GuardSync] can be provided to trigger re-evaluation of the current tree
/// when external conditions change (for example, when an authentication flag
/// flips and a redirect guard needs to run again).
/// {@endtemplate}
final class RouteNodeStateManager extends BaseStateManager {
  /// Subscription to the guard sync stream.
  StreamSubscription<GuardSyncReason?>? _guardSyncSubscription;

  /// {@macro guard_configuration}
  final RouteNodeGuard? _routeNodeGuard;

  /// {@macro guard_sync}
  final GuardSync? _guardSync;

  /// {@macro state_manager}
  ///
  /// [routeNode] is the initial tree. [routeNodeGuard] is the guard (or
  /// composite configuration) that runs on every mutation. [guardSync]
  /// optionally triggers re-evaluation of the current state.
  RouteNodeStateManager({
    required RouteNode routeNode,
    RouteNodeGuard? routeNodeGuard,
    GuardSync? guardSync,
    super.observer,
  })  : _routeNodeGuard = routeNodeGuard,
        _guardSync = guardSync,
        super(routeNode.toImmutable()) {
    _guardSyncSubscription = _guardSync?.stream.listen(_onReevaluate);
  }

  @override
  RouteNode mutate(MutateNodeCallback callback) {
    try {
      final target = callback(state.toMutable()).toImmutable();

      final result = _routeNodeGuard?.call(
        state,
        target,
        GuardContext(),
      );

      final nextState = switch (result) {
        GuardResultNext() => target,
        GuardResultRedirect(target: final redirect) => redirect,
        GuardResultCancel() => null,
        null => target,
      };

      if (nextState == null) {
        return state;
      }

      emit(nextState.toImmutable());
      return state;
    } on Object catch (error, stackTrace) {
      onError(error, stackTrace);
      rethrow;
    }
  }

  @mustCallSuper
  @override
  Future<void> close() async {
    await _guardSyncSubscription?.cancel();
    _guardSyncSubscription = null;
    return super.close();
  }

  /// Re-runs the guard pipeline against the current state.
  void _onReevaluate(GuardSyncReason reason) =>
      mutate((routeNode) => routeNode);
}
