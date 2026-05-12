import 'package:meta/meta.dart';

import '../../state/base/mutation.dart';
import '../route.dart';
import '../route_node.dart';
import 'route_node_diff_result.dart';

/// Signature for a callback invoked when a route is popped off the tree.
@experimental
typedef PopRouteMutationCallback = void Function(
  RouteNode origin,
  RouteNode target,
);

/// Signature for a callback invoked when a route is pushed onto the tree.
@experimental
typedef PushRouteMutationCallback = void Function(
  RouteNode origin,
  RouteNode target,
);

/// Signature for a callback invoked when an existing route is updated.
@experimental
typedef UpdateRouteMutationCallback = void Function(
  RouteNode origin,
  RouteNode target,
);

/// {@template yx_route_observer}
/// Observes push, pop and update operations that affect a specific route.
///
/// Attach an observer to a declaration to react whenever the route it owns
/// appears, disappears, or changes inside the navigation tree.
/// {@endtemplate}
@experimental
@immutable
class YxRouteObserver {
  /// Called when the observed route is removed from the tree.
  final PopRouteMutationCallback? onPop;

  /// Called when the observed route is added to the tree.
  final PushRouteMutationCallback? onPush;

  /// Called when the observed route's data changes.
  final UpdateRouteMutationCallback? onUpdate;

  /// {@macro yx_route_observer}
  const YxRouteObserver({
    this.onPop,
    this.onPush,
    this.onUpdate,
  });

  /// Called with every mutation that touched the observed route.
  ///
  /// The default implementation does nothing. Override it to inspect the
  /// full diff along with [mutation].
  void onRouteDiffMutation(Mutation mutation, RouteNodeDiffResult diff) {}
}

@experimental
final class RouteObserverAdapter extends YxRouteObserver {
  final YxRoute route;
  final YxRouteObserver? sourceObserver;

  const RouteObserverAdapter(
    this.route,
    this.sourceObserver,
  );

  @override
  void onRouteDiffMutation(Mutation mutation, RouteNodeDiffResult diff) {
    if (diff.isEmpty) {
      return;
    }

    if (diff.added.containsKey(route)) {
      return sourceObserver?.onPush
          ?.call(mutation.originalState, mutation.targetState);
    }

    if (diff.removed.containsKey(route)) {
      return sourceObserver?.onPop
          ?.call(mutation.originalState, mutation.targetState);
    }

    if (diff.updates.containsKey(route)) {
      return sourceObserver?.onUpdate
          ?.call(mutation.originalState, mutation.targetState);
    }
  }
}
