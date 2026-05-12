import '../../../yx_navigation.dart';

/// {@template route_node_readable}
/// Read-only access to the current [RouteNode] and its updates.
///
/// Consumers that only need to observe navigation state (without mutating
/// it) should depend on this interface rather than the concrete state
/// manager.
/// {@endtemplate}
abstract interface class RouteNodeReadable {
  /// A stream that emits the latest [RouteNode] whenever the state
  /// changes.
  Stream<RouteNode?> get stream;

  /// The current [RouteNode], or `null` if no state has been produced yet.
  RouteNode? get state;
}
