import '../base/route.dart';
import '../base/route_node.dart';

/// {@template yx_route_extension}
/// Convenience helpers for turning a [YxRoute] into a [RouteNode].
/// {@endtemplate}
extension RouteExtension on YxRoute {
  /// Creates a [RouteNode] for this route.
  ///
  /// The `children`, `arguments`, and `extra` parameters default to empty
  /// collections.
  RouteNode toNode({
    List<RouteNode> children = const [],
    Map<String, String> arguments = const {},
    Map<String, Object?> extra = const {},
  }) =>
      RouteNode.fromRoute(
        route: this,
        children: children,
        extra: extra,
        arguments: arguments,
      );

  /// Creates a [MutableRouteNode] for this route.
  ///
  /// Use when the resulting node needs to be mutated in place.
  MutableRouteNode toMutableNode({
    List<RouteNode> children = const [],
    Map<String, String> arguments = const {},
    Map<String, Object?> extra = const {},
  }) =>
      MutableRouteNode(
        route: this,
        children: children,
        extra: extra,
        arguments: arguments,
      );

  /// Creates an immutable route node for this route (same as
  /// [RouteNode.fromRoute] with this route).
  ///
  /// Use when the resulting node will be stored as the navigation state.
  ImmutableRouteNode toImmutableNode({
    List<RouteNode> children = const [],
    Map<String, String> arguments = const {},
    Map<String, Object?> extra = const {},
  }) =>
      ImmutableRouteNode(
        route: this,
        children: children,
        extra: extra,
        arguments: arguments,
      );
}
