import 'package:meta/meta.dart';

import '../../state/base/base_state_manager.dart';
import '../../state/base/mutation.dart';
import '../../state/base/state_manager_observer.dart';
import 'route_node_diff_result.dart';
import 'route_observer.dart';

/// {@template state_manager_diff_observer}
/// A [StateManagerObserver] that forwards each mutation to a list of
/// [YxRouteObserver]s along with the computed diff between the original and
/// target trees.
///
/// All other lifecycle callbacks are delegated to [sourceObserver] unchanged.
/// {@endtemplate}
@experimental
class StateManagerDiffObserver extends StateManagerObserver {
  /// Optional base observer that receives every state manager event.
  final StateManagerObserver? sourceObserver;

  /// Observers that are notified with the tree diff after each mutation.
  final List<YxRouteObserver> routeObservers;

  /// {@macro state_manager_diff_observer}
  const StateManagerDiffObserver({
    required this.sourceObserver,
    required this.routeObservers,
  });

  @override
  void onClose(BaseStateManager stateManager) {
    super.onClose(stateManager);
    sourceObserver?.onClose(stateManager);
  }

  @override
  void onCreate(BaseStateManager stateManager) {
    super.onCreate(stateManager);
    sourceObserver?.onCreate(stateManager);
  }

  @override
  void onError(
    BaseStateManager stateManager,
    Object error,
    StackTrace stackTrace,
  ) {
    super.onError(stateManager, error, stackTrace);
    sourceObserver?.onError(stateManager, error, stackTrace);
  }

  @override
  void onMutation(BaseStateManager stateManager, Mutation mutation) {
    super.onMutation(stateManager, mutation);
    sourceObserver?.onMutation(stateManager, mutation);

    if (routeObservers.isNotEmpty) {
      onRouteDiffMutation(mutation);
    }
  }

  /// Computes the diff for [mutation] and dispatches it to every
  /// registered [YxRouteObserver].
  @protected
  void onRouteDiffMutation(Mutation mutation) {
    final diff = RouteNodeDiffResult.difference(
      mutation.originalState,
      mutation.targetState,
    );

    if (diff.isEmpty) {
      return;
    }

    for (final observer in routeObservers) {
      observer.onRouteDiffMutation(mutation, diff);
    }
  }
}
