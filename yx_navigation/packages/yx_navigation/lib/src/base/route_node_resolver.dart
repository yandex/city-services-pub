import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'route.dart';
import 'route_node.dart';

/// {@template route_node_resolver}
/// Locates a [RouteNode] inside a tree rooted at another node.
///
/// Use [RouteNodeResolver.id] to match by [YxRoute] identity only, or
/// [RouteNodeResolver.full] to match by both [YxRoute] and arguments.
/// {@endtemplate}
abstract interface class RouteNodeResolver {
  /// Creates a resolver that matches nodes by [YxRoute] identity.
  const factory RouteNodeResolver.id({
    required YxRoute route,
  }) = RouteIDNodeResolver;

  /// Creates a resolver that matches nodes by both [YxRoute] and arguments.
  const factory RouteNodeResolver.full({
    required YxRoute route,
    required Map<String, String> arguments,
  }) = FullRouteNodeResolver;

  /// Traverses [routeNode] and returns the first matching node, or `null`.
  RouteNode? resolve(RouteNode routeNode);
}

/// Resolves a [RouteNode] by matching [YxRoute] identity only.
@immutable
class RouteIDNodeResolver implements RouteNodeResolver {
  final YxRoute _route;

  /// Creates a resolver that looks up nodes whose [RouteNode.route]
  /// equals [route].
  const RouteIDNodeResolver({
    required YxRoute route,
  }) : _route = route;

  @override
  RouteNode? resolve(RouteNode routeNode) => routeNode.findByRoute(_route);
}

/// Resolves a [RouteNode] by matching both [YxRoute] identity and
/// [RouteNode.arguments].
@immutable
class FullRouteNodeResolver implements RouteNodeResolver {
  final YxRoute _route;
  final Map<String, String> _arguments;

  /// Creates a resolver that matches a node whose route equals [route]
  /// and whose arguments equal [arguments].
  const FullRouteNodeResolver({
    required YxRoute route,
    required Map<String, String> arguments,
  })  : _route = route,
        _arguments = arguments;

  @override
  RouteNode? resolve(RouteNode routeNode) {
    RouteNode? findRouteNode;

    routeNode.traverse(
      (routeNode) {
        findRouteNode = routeNode;
        return true;
      },
      predicate: (routeNode) {
        final isNotFound = findRouteNode == null;
        final isEqualRoute = routeNode.route == _route;
        final isEqualArgs =
            const MapEquality().equals(routeNode.arguments, _arguments);
        return isNotFound && isEqualRoute && isEqualArgs;
      },
    );

    return findRouteNode;
  }
}
